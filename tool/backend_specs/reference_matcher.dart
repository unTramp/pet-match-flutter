import '../../backend/src/domain/spec_json.dart';
import '../../backend/src/domain/spec_models.dart';

export '../../backend/src/domain/spec_json.dart'
    show intList, intMap, loadJson, rankingFixturePaths, readPath, stringList;
export '../../backend/src/domain/spec_models.dart';
export '../../backend/src/domain/matcher.dart';

class ReferenceSpecBundle {
  const ReferenceSpecBundle({
    required this.config,
    required this.breeds,
    required this.fixtures,
  });

  factory ReferenceSpecBundle.load({
    String configPath = 'docs/backend/config/scoring_config.v2.json',
    String catalogPath = 'docs/backend/examples/catalog.v1.json',
    String fixturesDir = 'docs/backend/examples',
  }) {
    final config = ScoringConfig.fromJson(loadJson(configPath));
    final breeds = _loadBreeds(catalogPath: catalogPath);
    final fixtures = _loadRankingFixtures(fixturesDir: fixturesDir);
    return ReferenceSpecBundle(
      config: config,
      breeds: breeds,
      fixtures: fixtures,
    );
  }

  final ScoringConfig config;
  final Map<String, BreedFixture> breeds;
  final List<RankingFixture> fixtures;
}

Map<String, BreedFixture> _loadBreeds({required String catalogPath}) {
  final catalog = loadJson(catalogPath);
  final entries = List<Map<String, dynamic>>.from(
    catalog['breeds'] as List<dynamic>,
  );
  return {
    for (final entry in entries)
      entry['breedId'] as String: BreedFixture.fromJson(
        loadJson('docs/backend/examples/${entry['file']}'),
      ),
  };
}

List<RankingFixture> _loadRankingFixtures({required String fixturesDir}) =>
    rankingFixturePaths(
      fixturesDir: fixturesDir,
    ).map((path) => RankingFixture.fromJson(loadJson(path))).toList();
