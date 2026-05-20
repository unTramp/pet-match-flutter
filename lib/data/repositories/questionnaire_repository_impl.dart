import 'package:dio/dio.dart';

import '../../core/failures.dart';
import '../../core/logger.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/option.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/questionnaire_repository.dart';
import '../mappers/answer_mapper.dart';
import '../mappers/option_mapper.dart';
import '../mappers/session_mapper.dart';
import '../sources/pet_match_remote_source.dart';

/// Мост между data и domain. Перехватывает [DioException] и конвертирует
/// в типизированный [AppFailure]. Также ловит любые ошибки парсинга/каста
/// (`TypeError`, `FormatException`, и т.п.) — они мапятся в [ServerFailure]
/// с `statusCode: -1`, чтобы UI мог показать понятную ошибку, а не падал.
class QuestionnaireRepositoryImpl implements QuestionnaireRepository {
  QuestionnaireRepositoryImpl(this._source);

  final PetMatchRemoteSource _source;

  @override
  Future<Session> startSession(String externalId) => _guard(
    () async => SessionMapper.fromDto(
      await _source.startSession(externalId: externalId),
    ),
  );

  @override
  Future<Session> getSession(int userId) => _guard(
    () async => SessionMapper.fromDto(await _source.getSession(userId: userId)),
  );

  @override
  Future<Session> submitAnswer({
    required int userId,
    required UserAnswer answer,
  }) => _guard(() async {
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
  }) => _guard(
    () async => SessionMapper.fromDto(
      await _source.skipQuestion(userId: userId, questionId: questionId),
    ),
  );

  @override
  Future<List<DynamicOption>> getDynamicOptions({
    required int userId,
    required int questionId,
    String? query,
  }) => _guard(() async {
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

/// Универсальная обёртка: пробрасывает уже-типизированные [AppFailure],
/// маппит [DioException] и любые parse/runtime-ошибки в [ServerFailure(-1)].
Future<T> _guard<T>(Future<T> Function() body) async {
  try {
    return await body();
  } on AppFailure {
    rethrow;
  } on DioException catch (e) {
    throw _mapDioError(e);
  } catch (e, st) {
    appLogger.e('Repository parse/runtime error: $e', stackTrace: st);
    throw ServerFailure(statusCode: -1, message: 'Parse error: $e');
  }
}

AppFailure _mapDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const TimeoutFailure();
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return ServerFailure(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message ?? 'Unknown error',
      );
  }
}
