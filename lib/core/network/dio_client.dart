import 'package:dio/dio.dart';

import '../locale/app_locale_controller.dart';
import 'interceptors/locale_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

Dio buildDio(String baseUrl, AppLocaleController localeController) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.addAll([
    LocaleInterceptor(localeController: localeController),
    RetryInterceptor(dio: dio),
    LoggingInterceptor(),
  ]);

  return dio;
}
