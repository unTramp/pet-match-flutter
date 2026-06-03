import 'package:flutter_test/flutter_test.dart';
import '../../tool/backend_specs/reference_matcher.dart';

void main() {
  group('reference matcher ranking fixtures', () {
    late ReferenceSpecBundle bundle;

    setUpAll(() {
      bundle = ReferenceSpecBundle.load();
    });

    test('backend docs examples stay internally consistent', () {
      expect(bundle.breeds, isNotEmpty);
      expect(bundle.fixtures, hasLength(3));
      expect(
        bundle.fixtures.every(
          (fixture) => fixture.scoringVersion == bundle.config.version,
        ),
        isTrue,
      );
    });

    for (final fixtureFile in rankingFixturePaths()) {
      final fixture = RankingFixture.fromJson(loadJson(fixtureFile));
      test('fixture ${fixture.fixtureId} produces expected ranking', () {
        final results = ReferenceMatcher(
          config: bundle.config,
          breeds: bundle.breeds.values.toList(),
        ).rank(fixture.inputUserProfile);

        expect(results, isNotEmpty);

        final top = results.first;
        expect(top.breedId, fixture.expected.topBreedId);
        expect(
          top.matchPercent,
          inInclusiveRange(
            fixture.expected.topMatchPercentMin,
            fixture.expected.topMatchPercentMax,
          ),
        );

        final top3 = results.take(3).map((result) => result.breedId).toList();
        expect(
          top3.every(fixture.expected.acceptableTop3.contains),
          isTrue,
          reason:
              'Unexpected top-3 for ${fixture.fixtureId}: $top3. Allowed: ${fixture.expected.acceptableTop3}',
        );

        for (final pair in fixture.expected.mustRankAbove) {
          final higherIndex = results.indexWhere(
            (result) => result.breedId == pair.higher,
          );
          final lowerIndex = results.indexWhere(
            (result) => result.breedId == pair.lower,
          );
          expect(higherIndex, isNonNegative);
          expect(lowerIndex, isNonNegative);
          expect(
            higherIndex,
            lessThan(lowerIndex),
            reason:
                'Expected ${pair.higher} above ${pair.lower} in ${fixture.fixtureId}, got top order ${results.map((r) => '${r.breedId}:${r.matchPercent}').toList()}',
          );
        }
      });
    }
  });
}
