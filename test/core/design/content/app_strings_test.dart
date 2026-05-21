import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/core/design/content/app_strings.dart';
import 'package:pet_match/core/locale/app_locale_controller.dart';

void main() {
  tearDown(() {
    AppLocaleController.instance.setLanguage(AppLanguage.ru);
  });

  test('defaults to Russian strings', () {
    AppLocaleController.instance.setLanguage(AppLanguage.ru);

    expect(AppStrings.welcome.ctaStart, 'Подобрать питомца');
    expect(AppStrings.questionnaire.progressOf, 'из');
  });

  test('switches UI strings to English', () {
    AppLocaleController.instance.setLanguage(AppLanguage.en);

    expect(AppStrings.welcome.ctaStart, 'Find a pet');
    expect(AppStrings.questionnaire.progressOf, 'of');
  });
}
