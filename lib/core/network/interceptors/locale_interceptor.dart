import 'package:dio/dio.dart';

import '../../localization/locale_provider.dart';

/// Прикрепляет текущий язык к каждому исходящему запросу:
/// * параметр запроса `?locale=<code>` (как этого ждёт API);
/// * заголовок `Accept-Language` — общепринятый стандарт, удобен на бэке.
///
/// Локаль берётся из [LocaleProvider], а не хардкодится — это позволит
/// плавно переключать язык по пользовательской настройке без правки клиента.
class LocaleInterceptor extends Interceptor {
  LocaleInterceptor(this._localeProvider);

  final LocaleProvider _localeProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final code = _localeProvider.apiCode;
    if (!options.queryParameters.containsKey('locale')) {
      options.queryParameters['locale'] = code;
    }
    options.headers.putIfAbsent('Accept-Language', () => code);
    handler.next(options);
  }
}
