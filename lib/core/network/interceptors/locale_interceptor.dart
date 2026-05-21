import 'package:dio/dio.dart';

class LocaleInterceptor extends Interceptor {
  LocaleInterceptor({this.localeCode = 'ru'});

  final String localeCode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!options.queryParameters.containsKey('locale')) {
      options.queryParameters['locale'] = localeCode;
    }
    handler.next(options);
  }
}
