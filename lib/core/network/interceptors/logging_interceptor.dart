import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../logger.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      appLogger.d('→ ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      appLogger.d(
        '← ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      appLogger.e(
        '✗ ${err.requestOptions.method} ${err.requestOptions.uri} '
        '— ${err.type} ${err.response?.statusCode ?? ''}',
      );
    }
    handler.next(err);
  }
}
