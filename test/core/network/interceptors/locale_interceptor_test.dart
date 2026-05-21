import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/core/network/interceptors/locale_interceptor.dart';

class _FakeHandler extends RequestInterceptorHandler {
  RequestOptions? captured;
  @override
  void next(RequestOptions requestOptions) {
    captured = requestOptions;
  }
}

void main() {
  test('LocaleInterceptor добавляет locale по умолчанию', () {
    final interceptor = LocaleInterceptor();
    final options = RequestOptions(path: '/test');
    final handler = _FakeHandler();

    interceptor.onRequest(options, handler);

    expect(handler.captured?.queryParameters['locale'], 'ru');
  });

  test('LocaleInterceptor не перезатирает уже-присутствующий locale', () {
    final interceptor = LocaleInterceptor();
    final options = RequestOptions(
      path: '/test',
      queryParameters: {'locale': 'fr'},
    );
    final handler = _FakeHandler();

    interceptor.onRequest(options, handler);

    expect(handler.captured?.queryParameters['locale'], 'fr');
  });

  test('LocaleInterceptor позволяет переопределить localeCode', () {
    final interceptor = LocaleInterceptor(localeCode: 'en');
    final options = RequestOptions(path: '/test');
    final handler = _FakeHandler();

    interceptor.onRequest(options, handler);

    expect(handler.captured?.queryParameters['locale'], 'en');
  });
}
