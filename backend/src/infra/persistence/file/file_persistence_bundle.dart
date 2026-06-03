import '../../../repositories/file_spec_repositories.dart';
import 'file_match_result_repository.dart';
import 'file_spec_data_source.dart';
import '../persistence_bundle.dart';

class FilePersistenceBundle extends PersistenceBundle {
  FilePersistenceBundle({
    required FileSpecDataSource dataSource,
    required String storagePath,
  }) : super(
         questionnaireRepository: FileQuestionnaireRepository(dataSource),
         breedRepository: FileBreedRepository(dataSource),
         scoringConfigRepository: FileScoringConfigRepository(dataSource),
         matchResultRepository: FileMatchResultRepository(
           storagePath: storagePath,
         ),
         profileBuilderDefinition: dataSource.profileBuilderDefinition,
       );
}
