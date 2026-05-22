import '../../core/failures.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/option.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/questionnaire_repository.dart';
import '../mappers/answer_mapper.dart';
import '../mappers/option_mapper.dart';
import '../mappers/session_mapper.dart';
import '../network/dio_failure_mapper.dart';
import '../sources/pet_match_remote_source.dart';

/// Мост между data и domain. Все вызовы обёрнуты в [guardCall], который
/// конвертирует `DioException`/parse-ошибки в типизированный [AppFailure].
class QuestionnaireRepositoryImpl implements QuestionnaireRepository {
  QuestionnaireRepositoryImpl(this._source);

  final PetMatchRemoteSource _source;

  @override
  Future<Session> startSession(String externalId) => guardCall(
    () async => SessionMapper.fromDto(
      await _source.startSession(externalId: externalId),
    ),
  );

  @override
  Future<Session> getSession(int userId) => guardCall(
    () async => SessionMapper.fromDto(await _source.getSession(userId: userId)),
  );

  @override
  Future<Session> submitAnswer({
    required int userId,
    required UserAnswer answer,
  }) => guardCall(() async {
    final result = await _source.submitAnswer(
      userId: userId,
      answer: AnswerMapper.toDto(answer),
    );
    return SessionMapper.fromDto(result.session);
  });

  @override
  Future<Session> skipQuestion({
    required int userId,
    required int questionId,
  }) => guardCall(
    () async => SessionMapper.fromDto(
      await _source.skipQuestion(userId: userId, questionId: questionId),
    ),
  );

  @override
  Future<List<DynamicOption>> getDynamicOptions({
    required int userId,
    required int questionId,
    String? query,
  }) => guardCall(() async {
    final dto = await _source.getDynamicOptions(
      userId: userId,
      questionId: questionId,
      query: query,
    );
    if (dto.items.isEmpty && (query == null || query.isEmpty)) {
      throw const EmptyResponseFailure();
    }
    return dto.items.map(OptionMapper.fromDynamicDto).toList(growable: false);
  });
}
