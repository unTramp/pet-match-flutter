import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_match/core/locale/app_locale_controller.dart';
import 'package:pet_match/core/network/interceptors/locale_interceptor.dart';

class _MockController extends Mock implements AppLocaleController {}

class _FakeHandler extends RequestInterceptorHandler {
  RequestOptions? captured;
  @override
  void next(RequestOptions requestOptions) {
    captured = requestOptions;
  }
}

void main() {
  late _MockController controller;

  setUp(() {
    controller = _MockController();
    when(() => controller.current).thenReturn(AppLanguage.ru);
  });

  test('LocaleInterceptor добавляет locale из controller.current', () {
    final interceptor = LocaleInterceptor(localeController: controller);
    final options = RequestOptions(path: '/test');
    final handler = _FakeHandler();

    interceptor.onRequest(options, handler);

    expect(handler.captured?.queryParameters['locale'], 'ru');
  });

  test('LocaleInterceptor не перезатирает уже-присутствующий locale', () {
    final interceptor = LocaleInterceptor(localeController: controller);
    final options = RequestOptions(
      path: '/test',
      queryParameters: {'locale': 'fr'},
    );
    final handler = _FakeHandler();

    interceptor.onRequest(options, handler);

    expect(handler.captured?.queryParameters['locale'], 'fr');
  });

  test('LocaleInterceptor берёт актуальное значение при каждом запросе', () {
    final interceptor = LocaleInterceptor(localeController: controller);
    when(() => controller.current).thenReturn(AppLanguage.en);
    final options = RequestOptions(path: '/test');
    final handler = _FakeHandler();

    interceptor.onRequest(options, handler);

    expect(handler.captured?.queryParameters['locale'], 'en');
  });
}
