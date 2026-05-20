import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_match/core/failures.dart';
import 'package:pet_match/data/dto/answer_result_dto.dart';
import 'package:pet_match/data/dto/answer_submit_dto.dart';
import 'package:pet_match/data/dto/dynamic_option_dto.dart';
import 'package:pet_match/data/dto/session_dto.dart';
import 'package:pet_match/data/dto/stats_dto.dart';
import 'package:pet_match/data/dto/user_summary_dto.dart';
import 'package:pet_match/data/repositories/questionnaire_repository_impl.dart';
import 'package:pet_match/data/sources/pet_match_remote_source.dart';
import 'package:pet_match/domain/entities/answer.dart';

class _MockRemoteSource extends Mock implements PetMatchRemoteSource {}

class _FakeAnswerSubmitDto extends Fake implements AnswerSubmitDto {}

void main() {
  late _MockRemoteSource source;
  late QuestionnaireRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(_FakeAnswerSubmitDto());
  });

  setUp(() {
    source = _MockRemoteSource();
    repo = QuestionnaireRepositoryImpl(source);
  });

  DioException dioError(DioExceptionType type, {int? statusCode}) =>
      DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: type,
        response:
            statusCode != null
                ? Response(
                  requestOptions: RequestOptions(path: '/test'),
                  statusCode: statusCode,
                )
                : null,
        message: 'mock error',
      );

  group('error mapping', () {
    test('connectionError → NetworkFailure', () async {
      when(
        () => source.startSession(externalId: any(named: 'externalId')),
      ).thenThrow(dioError(DioExceptionType.connectionError));

      expect(
        () => repo.startSession('uid:test'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('connectionTimeout → TimeoutFailure', () async {
      when(
        () => source.startSession(externalId: any(named: 'externalId')),
      ).thenThrow(dioError(DioExceptionType.connectionTimeout));

      expect(
        () => repo.startSession('uid:test'),
        throwsA(isA<TimeoutFailure>()),
      );
    });

    test('badResponse 422 → ServerFailure(422)', () async {
      when(
        () => source.submitAnswer(
          userId: any(named: 'userId'),
          answer: any(named: 'answer'),
        ),
      ).thenThrow(dioError(DioExceptionType.badResponse, statusCode: 422));

      try {
        await repo.submitAnswer(
          userId: 1,
          answer: const SingleAnswer(questionId: 1, optionId: 1),
        );
        fail('expected ServerFailure');
      } on ServerFailure catch (f) {
        expect(f.statusCode, 422);
      }
    });
  });

  group('success mapping', () {
    const fakeSessionDto = SessionDto(
      user: UserSummaryDto(id: 7, externalId: 'uid:test'),
      stats: StatsDto(answeredCount: 0, totalCount: 5),
      nextQuestion: null,
      compatibility: null,
    );

    test('startSession returns mapped Session', () async {
      when(
        () => source.startSession(externalId: any(named: 'externalId')),
      ).thenAnswer((_) async => fakeSessionDto);

      final session = await repo.startSession('uid:test');

      expect(session.userId, 7);
      expect(session.progress.total, 5);
    });

    test('submitAnswer extracts session from AnswerResultDto', () async {
      when(
        () => source.submitAnswer(
          userId: any(named: 'userId'),
          answer: any(named: 'answer'),
        ),
      ).thenAnswer(
        (_) async => const AnswerResultDto(
          session: SessionDto(
            user: UserSummaryDto(id: 7),
            stats: StatsDto(answeredCount: 1, totalCount: 5),
          ),
        ),
      );

      final session = await repo.submitAnswer(
        userId: 7,
        answer: const SingleAnswer(questionId: 1, optionId: 10),
      );

      expect(session.userId, 7);
      expect(session.progress.answered, 1);
    });
  });

  group('parse error mapping', () {
    test(
      'TypeError/FormatException из source → ServerFailure(-1)',
      () async {
        when(
          () => source.startSession(externalId: any(named: 'externalId')),
        ).thenThrow(const FormatException('bad json'));

        try {
          await repo.startSession('uid:test');
          fail('expected ServerFailure');
        } on ServerFailure catch (f) {
          expect(f.statusCode, -1);
          expect(f.message, contains('Parse error'));
        }
      },
    );

    test('Уже-типизированный AppFailure rethrows как есть', () async {
      when(
        () => source.getDynamicOptions(
          userId: any(named: 'userId'),
          questionId: any(named: 'questionId'),
          query: any(named: 'query'),
        ),
      ).thenAnswer((_) async => const DynamicOptionListDto(questionId: 1));

      // EmptyResponseFailure кидается внутри _guard — должен пройти насквозь,
      // не переупаковаться в ServerFailure(-1).
      expect(
        () => repo.getDynamicOptions(userId: 1, questionId: 1),
        throwsA(isA<EmptyResponseFailure>()),
      );
    });
  });

  group('getDynamicOptions', () {
    test('пустой список без query → EmptyResponseFailure', () async {
      when(
        () => source.getDynamicOptions(
          userId: any(named: 'userId'),
          questionId: any(named: 'questionId'),
          query: any(named: 'query'),
        ),
      ).thenAnswer((_) async => const DynamicOptionListDto(questionId: 1));

      expect(
        () => repo.getDynamicOptions(userId: 1, questionId: 1),
        throwsA(isA<EmptyResponseFailure>()),
      );
    });

    test(
      'пустой список с query → возвращается пустой список (нет ошибки)',
      () async {
        when(
          () => source.getDynamicOptions(
            userId: any(named: 'userId'),
            questionId: any(named: 'questionId'),
            query: any(named: 'query'),
          ),
        ).thenAnswer((_) async => const DynamicOptionListDto(questionId: 1));

        final options = await repo.getDynamicOptions(
          userId: 1,
          questionId: 1,
          query: 'foo',
        );

        expect(options, isEmpty);
      },
    );
  });
}
