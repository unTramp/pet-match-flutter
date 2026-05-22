import 'package:dio/dio.dart';

import '../../core/failures.dart';
import '../../core/logger.dart';

/// Маппинг [DioException] в типизированный [AppFailure].
///
/// Используется во всех репозиториях, чтобы наружу data-слоя
/// никогда не утекал транспортный тип `DioException`.
AppFailure mapDioToFailure(DioException e) {
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

/// Универсальная обёртка для repository-вызовов:
/// * уже типизированные [AppFailure] пробрасываются как есть;
/// * [DioException] → соответствующий [AppFailure];
/// * любые парс/runtime-ошибки → [ServerFailure(-1)] с сообщением.
Future<T> guardCall<T>(Future<T> Function() body) async {
  try {
    return await body();
  } on AppFailure {
    rethrow;
  } on DioException catch (e) {
    throw mapDioToFailure(e);
  } catch (e, st) {
    appLogger.e('Repository parse/runtime error: $e', stackTrace: st);
    throw ServerFailure(statusCode: -1, message: 'Parse error: $e');
  }
}
