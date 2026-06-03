import '../../../repositories/file_spec_repositories.dart';
import '../file/file_spec_data_source.dart';
import '../persistence_bundle.dart';
import 'postgres_match_result_repository.dart';

class PostgresPersistenceBundle extends PersistenceBundle {
  PostgresPersistenceBundle({
    required FileSpecDataSource dataSource,
    required String databaseUrl,
  }) : super(
         questionnaireRepository: FileQuestionnaireRepository(dataSource),
         breedRepository: FileBreedRepository(dataSource),
         scoringConfigRepository: FileScoringConfigRepository(dataSource),
         matchResultRepository: PostgresMatchResultRepository(
           databaseUrl: databaseUrl,
         ),
         profileBuilderDefinition: dataSource.profileBuilderDefinition,
       );
}
