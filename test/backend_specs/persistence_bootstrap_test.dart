import 'package:flutter_test/flutter_test.dart';

import '../../backend/src/config/runtime_config.dart';
import '../../backend/src/infra/logging/app_logger.dart';
import '../../backend/src/infra/persistence/file/file_persistence_bundle.dart';
import '../../backend/src/infra/persistence/persistence_bootstrap.dart';
import '../../backend/src/infra/persistence/postgres/postgres_persistence_bundle.dart';

void main() {
  group('persistence bootstrap', () {
    test('builds file persistence bundle by default', () {
      final config = RuntimeConfig(
        host: '127.0.0.1',
        port: 8080,
        environment: RuntimeEnvironment.development,
        logLevel: LogLevel.info,
        questionnaireVersion: 1,
        scoringVersion: 2,
        catalogVersion: 1,
        storagePath: 'backend/storage',
        storageDriver: StorageDriver.file,
        databaseUrl: '',
        exposeErrorDetails: true,
        matchResultRetentionDays: 30,
        maxStoredMatchResults: 2000,
      );

      final bundle = PersistenceBootstrap.create(
        runtimeConfig: config,
        logger: AppLogger(level: LogLevel.error, serviceName: 'test'),
      );

      expect(bundle, isA<FilePersistenceBundle>());
    });

    test(
      'builds postgres persistence bundle when database url is configured',
      () {
        final config = RuntimeConfig(
          host: '127.0.0.1',
          port: 8080,
          environment: RuntimeEnvironment.production,
          logLevel: LogLevel.info,
          questionnaireVersion: 1,
          scoringVersion: 2,
          catalogVersion: 1,
          storagePath: '/srv/petwise/data',
          storageDriver: StorageDriver.postgres,
          databaseUrl: 'postgres://petwise:secret@db:5432/petwise',
          exposeErrorDetails: false,
          matchResultRetentionDays: 30,
          maxStoredMatchResults: 2000,
        );

        final bundle = PersistenceBootstrap.create(
          runtimeConfig: config,
          logger: AppLogger(level: LogLevel.error, serviceName: 'test'),
        );

        expect(bundle, isA<PostgresPersistenceBundle>());
      },
    );

    test('fails fast for postgres when database url is missing', () {
      final config = RuntimeConfig(
        host: '127.0.0.1',
        port: 8080,
        environment: RuntimeEnvironment.production,
        logLevel: LogLevel.info,
        questionnaireVersion: 1,
        scoringVersion: 2,
        catalogVersion: 1,
        storagePath: '/srv/petwise/data',
        storageDriver: StorageDriver.postgres,
        databaseUrl: '',
        exposeErrorDetails: false,
        matchResultRetentionDays: 30,
        maxStoredMatchResults: 2000,
      );

      expect(
        () => PersistenceBootstrap.create(
          runtimeConfig: config,
          logger: AppLogger(level: LogLevel.error, serviceName: 'test'),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
