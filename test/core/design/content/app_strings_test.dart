import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/core/design/content/app_strings.dart';

void main() {
  test('exposes Russian user-facing strings', () {
    expect(AppStrings.welcome.ctaStart, 'Подобрать питомца');
    expect(AppStrings.questionnaire.progressOf, 'из');
    expect(AppStrings.common.appBrand, 'PET MATCH AI');
    expect(AppStrings.analyzing.title, 'Подбираем породу…');
  });
}
