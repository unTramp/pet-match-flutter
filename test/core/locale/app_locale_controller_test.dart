import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/core/locale/app_locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppLocaleController', () {
    test('init() defaults to ru when no saved value', () async {
      final prefs = await SharedPreferences.getInstance();
      final controller = AppLocaleController.debugCreate(prefs: prefs);

      await controller.init();

      expect(controller.current, AppLanguage.ru);
    });

    test('init() restores saved language from prefs', () async {
      SharedPreferences.setMockInitialValues({'app_language': 'en'});
      final prefs = await SharedPreferences.getInstance();
      final controller = AppLocaleController.debugCreate(prefs: prefs);

      await controller.init();

      expect(controller.current, AppLanguage.en);
    });

    test('setLanguage() persists choice to prefs', () async {
      final prefs = await SharedPreferences.getInstance();
      final controller = AppLocaleController.debugCreate(prefs: prefs);

      await controller.setLanguage(AppLanguage.en);

      expect(controller.current, AppLanguage.en);
      expect(prefs.getString('app_language'), 'en');
    });

    test('setLanguage() with same value does not write again', () async {
      SharedPreferences.setMockInitialValues({'app_language': 'ru'});
      final prefs = await SharedPreferences.getInstance();
      final controller = AppLocaleController.debugCreate(prefs: prefs);

      var notified = 0;
      controller.addListener(() => notified++);
      await controller.setLanguage(AppLanguage.ru);

      expect(notified, 0);
    });

    test('AppLanguage.fromCode parses known codes, returns null otherwise',
        () {
      expect(AppLanguage.fromCode('ru'), AppLanguage.ru);
      expect(AppLanguage.fromCode('en'), AppLanguage.en);
      expect(AppLanguage.fromCode('xx'), isNull);
      expect(AppLanguage.fromCode(null), isNull);
    });
  });
}
