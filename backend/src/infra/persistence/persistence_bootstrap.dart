import '../../config/runtime_config.dart';
import '../../infra/logging/app_logger.dart';
import 'file/file_persistence_bundle.dart';
import 'file/file_spec_data_source.dart';
import 'persistence_bundle.dart';
import 'postgres/postgres_persistence_bundle.dart';

class PersistenceBootstrap {
  const PersistenceBootstrap._();

  static PersistenceBundle create({
    required RuntimeConfig runtimeConfig,
    required AppLogger logger,
  }) {
    switch (runtimeConfig.storageDriver) {
      case StorageDriver.file:
        logger.info(
          'persistence.bootstrap',
          fields: <String, Object?>{
            'driver': runtimeConfig.storageDriver.name,
            'storagePath': runtimeConfig.storagePath,
          },
        );
        final dataSource = FileSpecDataSource(paths: runtimeConfig.specPaths);
        return FilePersistenceBundle(
          dataSource: dataSource,
          storagePath: runtimeConfig.storagePath,
        );
      case StorageDriver.postgres:
        if (runtimeConfig.databaseUrl.isEmpty) {
          throw ArgumentError(
            'DATABASE_URL must be configured when PETWISE_STORAGE_DRIVER=postgres.',
          );
        }
        logger.info(
          'persistence.bootstrap',
          fields: <String, Object?>{
            'driver': runtimeConfig.storageDriver.name,
            'databaseUrlConfigured': runtimeConfig.databaseUrl.isNotEmpty,
          },
        );
        final dataSource = FileSpecDataSource(paths: runtimeConfig.specPaths);
        return PostgresPersistenceBundle(
          dataSource: dataSource,
          databaseUrl: runtimeConfig.databaseUrl,
        );
    }
  }
}
