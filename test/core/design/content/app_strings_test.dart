import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/core/design/content/app_strings.dart';
import 'package:pet_match/core/locale/app_locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await AppLocaleController.instance.setLanguage(AppLanguage.ru);
  });

  test('defaults to Russian strings', () async {
    await AppLocaleController.instance.setLanguage(AppLanguage.ru);

    expect(AppStrings.welcome.ctaStart, 'Подобрать питомца');
    expect(AppStrings.questionnaire.progressOf, 'из');
  });

  test('switches UI strings to English', () async {
    await AppLocaleController.instance.setLanguage(AppLanguage.en);

    expect(AppStrings.welcome.ctaStart, 'Find a pet');
    expect(AppStrings.questionnaire.progressOf, 'of');
  });
}
