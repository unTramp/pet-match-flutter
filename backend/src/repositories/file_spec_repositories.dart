import '../domain/spec_models.dart';
import '../infra/persistence/file/file_spec_data_source.dart';
import 'breed_repository.dart';
import 'questionnaire_repository.dart';
import 'scoring_config_repository.dart';

class FileQuestionnaireRepository implements QuestionnaireRepository {
  const FileQuestionnaireRepository(this._dataSource);

  final FileSpecDataSource _dataSource;

  @override
  Map<String, dynamic> getActiveDefinition() => _dataSource.questionnaireJson;

  @override
  int getActiveVersion() =>
      (_dataSource.questionnaireJson['questionnaireVersion'] as num).toInt();
}

class FileBreedRepository implements BreedRepository {
  const FileBreedRepository(this._dataSource);

  final FileSpecDataSource _dataSource;

  @override
  Map<String, dynamic>? getBreedById(String breedId) =>
      _dataSource.breedJsonById[breedId];

  @override
  List<BreedFixture> listBreedFixtures() =>
      _dataSource.breedFixturesById.values.toList(growable: false);
}

class FileScoringConfigRepository implements ScoringConfigRepository {
  const FileScoringConfigRepository(this._dataSource);

  final FileSpecDataSource _dataSource;

  @override
  ScoringConfig getActiveConfig() => _dataSource.scoringConfig;

  @override
  List<Map<String, dynamic>> getLabels() => List<Map<String, dynamic>>.from(
    _dataSource.scoringConfigJson['labels'] as List<dynamic>,
  );

  @override
  int getActiveVersion() => _dataSource.scoringConfig.version;
}
