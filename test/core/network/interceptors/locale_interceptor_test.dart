import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/core/localization/locale_provider.dart';
import 'package:pet_match/core/network/interceptors/locale_interceptor.dart';

class _FakeHandler extends RequestInterceptorHandler {
  RequestOptions? captured;
  @override
  void next(RequestOptions requestOptions) {
    captured = requestOptions;
  }
}

LocaleInterceptor _interceptor(String code) =>
    LocaleInterceptor(StaticLocaleProvider(Locale(code)));

void main() {
  test('LocaleInterceptor добавляет locale из provider', () {
    final interceptor = _interceptor('ru');
    final options = RequestOptions(path: '/test');
    final handler = _FakeHandler();

    interceptor.onRequest(options, handler);

    expect(handler.captured?.queryParameters['locale'], 'ru');
    expect(handler.captured?.headers['Accept-Language'], 'ru');
  });

  test('LocaleInterceptor не перезатирает уже-присутствующий locale', () {
    final interceptor = _interceptor('ru');
    final options = RequestOptions(
      path: '/test',
      queryParameters: {'locale': 'fr'},
    );
    final handler = _FakeHandler();

    interceptor.onRequest(options, handler);

    expect(handler.captured?.queryParameters['locale'], 'fr');
  });

  test('LocaleInterceptor берёт код из provider', () {
    final interceptor = _interceptor('en');
    final options = RequestOptions(path: '/test');
    final handler = _FakeHandler();

    interceptor.onRequest(options, handler);

    expect(handler.captured?.queryParameters['locale'], 'en');
    expect(handler.captured?.headers['Accept-Language'], 'en');
  });
}
