import '../../../domain/profile_builder.dart';
import '../../../domain/spec_json.dart';
import '../../../domain/spec_models.dart';
import '../../../spec_paths.dart';

class FileSpecDataSource {
  FileSpecDataSource({required this.paths}) {
    questionnaireJson = loadJson(paths.questionnairePath);
    mappingJson = loadJson(paths.mappingPath);
    scoringConfigJson = loadJson(paths.scoringConfigPath);
    catalogJson = loadJson(paths.catalogPath);
    profileBuilderDefinition = ProfileBuilderDefinition.fromJson(
      questionnaireJson: questionnaireJson,
      mappingJson: mappingJson,
      scoringConfigJson: scoringConfigJson,
    );
    scoringConfig = ScoringConfig.fromJson(scoringConfigJson);
    breedJsonById = <String, Map<String, dynamic>>{};
    breedFixturesById = <String, BreedFixture>{};

    final entries = catalogEntries;
    for (final entry in entries) {
      final breedId = entry['breedId'] as String;
      final fileName = entry['file'] as String;
      final json = loadJson('${paths.examplesDir}/$fileName');
      breedJsonById[breedId] = json;
      breedFixturesById[breedId] = BreedFixture.fromJson(json);
    }
  }

  final BackendSpecPaths paths;
  late final Map<String, dynamic> questionnaireJson;
  late final Map<String, dynamic> mappingJson;
  late final Map<String, dynamic> scoringConfigJson;
  late final Map<String, dynamic> catalogJson;
  late final ProfileBuilderDefinition profileBuilderDefinition;
  late final ScoringConfig scoringConfig;
  late final Map<String, Map<String, dynamic>> breedJsonById;
  late final Map<String, BreedFixture> breedFixturesById;

  List<Map<String, dynamic>> get catalogEntries =>
      List<Map<String, dynamic>>.from(catalogJson['breeds'] as List<dynamic>);
}
