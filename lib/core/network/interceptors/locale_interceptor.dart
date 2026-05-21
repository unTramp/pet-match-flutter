import 'package:dio/dio.dart';

import '../../locale/app_locale_controller.dart';

class LocaleInterceptor extends Interceptor {
  LocaleInterceptor({AppLocaleController? localeController})
    : _localeController = localeController ?? AppLocaleController.instance;

  final AppLocaleController _localeController;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!options.queryParameters.containsKey('locale')) {
      options.queryParameters['locale'] = _localeController.current.code;
    }
    handler.next(options);
  }
}
