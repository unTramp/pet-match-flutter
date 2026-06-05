import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_match/core/cache/questionnaire_draft_cache.dart';
import 'package:pet_match/core/failures.dart';
import 'package:pet_match/data/dto/compatibility_dto.dart';
import 'package:pet_match/data/dto/petwise_match_preview_dto.dart';
import 'package:pet_match/data/dto/petwise_profile_dto.dart';
import 'package:pet_match/data/dto/petwise_questionnaire_definition_dto.dart';
import 'package:pet_match/data/repositories/questionnaire_repository_impl.dart';
import 'package:pet_match/data/sources/petwise_remote_source.dart';
import 'package:pet_match/domain/entities/answer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockPetWiseRemoteSource extends Mock implements PetWiseRemoteSource {}

void main() {
  late _MockPetWiseRemoteSource source;
  late QuestionnaireRepositoryImpl repo;

  const definition = PetWiseQuestionnaireDefinitionDto(
    questionnaireVersion: 1,
    questions: [
      PetWiseQuestionDto(
        id: 'pet_type',
        order: 1,
        kind: 'single_choice',
        isRequired: true,
        title: 'Какой питомец вас интересует?',
        options: [
          PetWiseQuestionOptionDto(id: 'dog', label: 'Собака'),
          PetWiseQuestionOptionDto(id: 'cat', label: 'Кошка'),
        ],
      ),
      PetWiseQuestionDto(
        id: 'home_type',
        order: 2,
        kind: 'single_choice',
        isRequired: true,
        title: 'Где вы живете?',
        options: [
          PetWiseQuestionOptionDto(id: 'apartment', label: 'Квартира'),
          PetWiseQuestionOptionDto(id: 'house', label: 'Дом'),
        ],
      ),
    ],
  );

  DioException dioError(DioExceptionType type, {int? statusCode}) =>
      DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: type,
        response:
            statusCode == null
                ? null
                : Response<void>(
                  requestOptions: RequestOptions(path: '/test'),
                  statusCode: statusCode,
                ),
        message: 'mock error',
      );

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    source = _MockPetWiseRemoteSource();
    repo = QuestionnaireRepositoryImpl(source, QuestionnaireDraftCache());
  });

  group('error mapping', () {
    test('connectionError → NetworkFailure', () async {
      when(() => source.getQuestionnaireDefinition()).thenThrow(
        dioError(DioExceptionType.connectionError),
      );

      expect(() => repo.startSession('uid:test'), throwsA(isA<NetworkFailure>()));
    });

    test('connectionTimeout → TimeoutFailure', () async {
      when(() => source.getQuestionnaireDefinition()).thenThrow(
        dioError(DioExceptionType.connectionTimeout),
      );

      expect(() => repo.startSession('uid:test'), throwsA(isA<TimeoutFailure>()));
    });

    test('badResponse 422 during match preview → ServerFailure(422)', () async {
      when(() => source.getQuestionnaireDefinition()).thenAnswer((_) async => definition);
      when(
        () => source.buildProfile(
          questionnaireVersion: any(named: 'questionnaireVersion'),
          answers: any(named: 'answers'),
        ),
      ).thenAnswer(
        (_) async => const PetWiseProfileResponseDto(
          questionnaireVersion: 1,
          userProfile: {'petType': 'dog'},
        ),
      );
      when(
        () => source.previewMatch(
          questionnaireVersion: any(named: 'questionnaireVersion'),
          userProfile: any(named: 'userProfile'),
        ),
      ).thenThrow(dioError(DioExceptionType.badResponse, statusCode: 422));

      await repo.startSession('uid:test');
      await repo.submitAnswer(
        userId: 1,
        answer: const SingleAnswer(questionId: 1, optionId: 1),
      );

      try {
        await repo.submitAnswer(
          userId: 1,
          answer: const SingleAnswer(questionId: 2, optionId: 1),
        );
        fail('expected ServerFailure');
      } on ServerFailure catch (f) {
        expect(f.statusCode, 422);
      }
    });
  });

  group('success flow', () {
    test('startSession returns first local question from questionnaire definition', () async {
      when(() => source.getQuestionnaireDefinition()).thenAnswer((_) async => definition);

      final session = await repo.startSession('uid:test');

      expect(session.userId, 1);
      expect(session.progress.answered, 0);
      expect(session.progress.total, 2);
      expect(session.nextQuestion?.id, 1);
      expect(session.nextQuestion?.title, 'Какой питомец вас интересует?');
    });

    test('submitAnswer completes local draft and resolves compatibility', () async {
      when(() => source.getQuestionnaireDefinition()).thenAnswer((_) async => definition);
      when(
        () => source.buildProfile(
          questionnaireVersion: any(named: 'questionnaireVersion'),
          answers: any(named: 'answers'),
        ),
      ).thenAnswer(
        (_) async => const PetWiseProfileResponseDto(
          questionnaireVersion: 1,
          userProfile: {'petType': 'dog', 'apartmentSuitability': 5},
        ),
      );
      when(
        () => source.previewMatch(
          questionnaireVersion: any(named: 'questionnaireVersion'),
          userProfile: any(named: 'userProfile'),
        ),
      ).thenAnswer(
        (_) async => const PetWiseMatchPreviewDto(
          questionnaireVersion: 1,
          scoringVersion: 2,
          compatibility: CompatibilityDto(
            status: 'ready',
            breedId: 'whippet',
            breedName: 'Уиппет',
            score: 91,
          ),
        ),
      );

      await repo.startSession('uid:test');

      final secondQuestionSession = await repo.submitAnswer(
        userId: 1,
        answer: const SingleAnswer(questionId: 1, optionId: 1),
      );
      expect(secondQuestionSession.nextQuestion?.id, 2);
      expect(secondQuestionSession.compatibility, isNull);

      final completed = await repo.submitAnswer(
        userId: 1,
        answer: const SingleAnswer(questionId: 2, optionId: 1),
      );

      expect(completed.nextQuestion, isNull);
      expect(completed.compatibility, isNotNull);
      expect(completed.compatibility?.breedId, 'whippet');
      expect(completed.compatibility?.score, 0.91);
    });
  });

  test('getDynamicOptions returns empty list for v1 local questionnaire flow', () async {
    final options = await repo.getDynamicOptions(userId: 1, questionId: 1);
    expect(options, isEmpty);
  });

  test('FormatException from source → ServerFailure(-1)', () async {
    when(() => source.getQuestionnaireDefinition()).thenThrow(
      const FormatException('bad json'),
    );

    try {
      await repo.startSession('uid:test');
      fail('expected ServerFailure');
    } on ServerFailure catch (f) {
      expect(f.statusCode, -1);
      expect(f.message, contains('Parse error'));
    }
  });
}
