import 'package:dio/dio.dart';

class LocaleInterceptor extends Interceptor {
  LocaleInterceptor({this.locale = 'ru'});

  final String locale;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!options.queryParameters.containsKey('locale')) {
      options.queryParameters['locale'] = locale;
    }
    handler.next(options);
  }
}
