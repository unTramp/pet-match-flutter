import 'package:flutter_test/flutter_test.dart';

import '../../backend/src/services/match_explanation_builder.dart';
import '../../tool/backend_specs/reference_matcher.dart';

void main() {
  group('match explainability', () {
    late ReferenceSpecBundle bundle;
    late ReferenceMatcher matcher;
    late MatchExplanationBuilder builder;

    setUpAll(() {
      bundle = ReferenceSpecBundle.load();
      matcher = ReferenceMatcher(
        config: bundle.config,
        breeds: bundle.breeds.values.toList(),
      );
      builder = const MatchExplanationBuilder();
    });

    test('stores triggered cap reasons for mismatched breeds', () {
      final profile = RankingFixture.fromJson(
        loadJson(
          'docs/backend/examples/ranking_case.apartment_quiet_beginner.json',
        ),
      ).inputUserProfile;

      final results = matcher.rank(profile);
      final borderCollie = results.firstWhere(
        (result) => result.breedId == 'border_collie',
      );

      expect(borderCollie.triggeredCapReasons, contains('low_apartment_fit'));
      expect(borderCollie.triggeredCapReasons, contains('low_beginner_fit'));
      expect(
        borderCollie.contributions.any(
          (contribution) =>
              contribution.field == 'apartmentSuitability' &&
              contribution.penalty > 0,
        ),
        isTrue,
      );
    });

    test('builds warning and matches from personalized contributions', () {
      final profile = RankingFixture.fromJson(
        loadJson(
          'docs/backend/examples/ranking_case.apartment_quiet_beginner.json',
        ),
      ).inputUserProfile;
      final results = matcher.rank(profile);

      final topResult = results.first;
      final topBreed = loadJson(
        'docs/backend/examples/breed.${topResult.breedId}.json',
      );
      final topExplanation = builder.build(
        breedJson: topBreed,
        matchResult: topResult,
        scoringConfig: bundle.config,
      );

      expect(topExplanation.strongMatches, contains('Подходит для квартиры'));
      expect(topExplanation.strongMatches, contains('Уход'));

      final borderCollie = results.firstWhere(
        (result) => result.breedId == 'border_collie',
      );
      final borderCollieJson = loadJson(
        'docs/backend/examples/breed.border_collie.json',
      );
      final borderCollieExplanation = builder.build(
        breedJson: borderCollieJson,
        matchResult: borderCollie,
        scoringConfig: bundle.config,
      );

      expect(
        borderCollieExplanation.warning,
        bundle.config.capReasonMessages['low_apartment_fit'],
      );
      expect(
        borderCollieExplanation.weakMatches,
        contains('Подходит для квартиры'),
      );
    });
  });
}
