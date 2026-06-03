class BackendSpecPaths {
  const BackendSpecPaths({
    required this.questionnairePath,
    required this.mappingPath,
    required this.scoringConfigPath,
    required this.catalogPath,
    required this.examplesDir,
  });

  factory BackendSpecPaths.v1() {
    return const BackendSpecPaths(
      questionnairePath:
          'docs/backend/examples/questionnaire_definition.v1.json',
      mappingPath: 'docs/backend/config/answer_to_profile_mapping.v1.json',
      scoringConfigPath: 'docs/backend/config/scoring_config.v1.json',
      catalogPath: 'docs/backend/examples/catalog.v1.json',
      examplesDir: 'docs/backend/examples',
    );
  }

  factory BackendSpecPaths.fromVersions({
    required int questionnaireVersion,
    required int scoringVersion,
    required int catalogVersion,
  }) {
    return BackendSpecPaths(
      questionnairePath:
          'docs/backend/examples/questionnaire_definition.v$questionnaireVersion.json',
      mappingPath:
          'docs/backend/config/answer_to_profile_mapping.v$questionnaireVersion.json',
      scoringConfigPath:
          'docs/backend/config/scoring_config.v$scoringVersion.json',
      catalogPath: 'docs/backend/examples/catalog.v$catalogVersion.json',
      examplesDir: 'docs/backend/examples',
    );
  }

  final String questionnairePath;
  final String mappingPath;
  final String scoringConfigPath;
  final String catalogPath;
  final String examplesDir;
}
