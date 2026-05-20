import 'package:dio/dio.dart';

import '../../core/failures.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/option.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/questionnaire_repository.dart';
import '../mappers/answer_mapper.dart';
import '../mappers/option_mapper.dart';
import '../mappers/session_mapper.dart';
import '../sources/pet_match_remote_source.dart';

/// Мост между data и domain. Перехватывает `DioException` и конвертирует
/// в типизированный [AppFailure]. Никаких сетевых исключений выше не уходит.
class QuestionnaireRepositoryImpl implements QuestionnaireRepository {
  QuestionnaireRepositoryImpl(this._source);

  final PetMatchRemoteSource _source;

  @override
  Future<Session> startSession(String externalId) async {
    try {
      final dto = await _source.startSession(externalId: externalId);
      return SessionMapper.fromDto(dto);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Session> getSession(int userId) async {
    try {
      final dto = await _source.getSession(userId: userId);
      return SessionMapper.fromDto(dto);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Session> submitAnswer({
    required int userId,
    required UserAnswer answer,
  }) async {
    try {
      final result = await _source.submitAnswer(
        userId: userId,
        answer: AnswerMapper.toDto(answer),
      );
      return SessionMapper.fromDto(result.session);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Session> skipQuestion({
    required int userId,
    required int questionId,
  }) async {
    try {
      final dto = await _source.skipQuestion(
        userId: userId,
        questionId: questionId,
      );
      return SessionMapper.fromDto(dto);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<DynamicOption>> getDynamicOptions({
    required int userId,
    required int questionId,
    String? query,
  }) async {
    try {
      final dto = await _source.getDynamicOptions(
        userId: userId,
        questionId: questionId,
        query: query,
      );
      if (dto.items.isEmpty && (query == null || query.isEmpty)) {
        throw const EmptyResponseFailure();
      }
      return dto.items.map(OptionMapper.fromDynamicDto).toList(growable: false);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
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
