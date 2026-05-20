import 'package:dio/dio.dart';

import '../../logger.dart';

/// Повторяет запрос при сетевых таймаутах / connection-ошибках.
///
/// Максимум 3 попытки. Backoff экспоненциальный: 1s → 2s → 4s.
/// Server 4xx/5xx **не** ретраются — они должны прокидываться вверх как `ServerFailure`.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({this.maxRetries = 3, Dio? dio}) : _dio = dio;

  final int maxRetries;
  final Dio? _dio;

  static const _retryCountKey = 'retryCount';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryable =
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;

    final attempt = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;

    if (!retryable || attempt >= maxRetries - 1) {
      handler.next(err);
      return;
    }

    final delay = Duration(seconds: 1 << attempt); // 1s, 2s, 4s
    appLogger.w(
      'Retry #${attempt + 1} after $delay for ${err.requestOptions.uri}',
    );
    await Future<void>.delayed(delay);

    final updatedOptions =
        err.requestOptions.copyWith()..extra[_retryCountKey] = attempt + 1;

    final client = _dio ?? Dio();
    try {
      final response = await client.fetch<dynamic>(updatedOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
