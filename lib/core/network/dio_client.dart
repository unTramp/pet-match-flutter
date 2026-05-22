import 'package:dio/dio.dart';

import '../constants.dart';
import '../localization/locale_provider.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/locale_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

Dio buildDio(String baseUrl, LocaleProvider localeProvider) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: kRequestTimeout,
      sendTimeout: const Duration(seconds: 10),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      responseType: ResponseType.json,
    ),
  );

  // Порядок: Auth → Locale → Retry → Logging. Auth первым, чтобы заголовок
  // присутствовал во всех ретраях; Logging — последним, чтобы видеть финальный
  // запрос/ответ.
  dio.interceptors.addAll([
    AuthInterceptor(),
    LocaleInterceptor(localeProvider),
    RetryInterceptor(dio: dio),
    LoggingInterceptor(),
  ]);

  return dio;
}
