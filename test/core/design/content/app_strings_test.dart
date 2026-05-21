import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/core/design/content/app_strings.dart';

void main() {
  test('defaults to Russian strings', () async {
    expect(AppStrings.welcome.ctaStart, 'Подобрать питомца');
    expect(AppStrings.questionnaire.progressOf, 'из');
    expect(AppStrings.analyzing.title, 'Подбираем породу…');
  });
}
