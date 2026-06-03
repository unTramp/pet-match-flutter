import 'package:flutter_test/flutter_test.dart';

import '../../backend/src/config/runtime_config.dart';

void main() {
  group('runtime config', () {
    test('reads values from args and environment', () {
      final config = RuntimeConfig.fromArgs(
        <String>['--port', '9090', '--log-level', 'debug'],
        environment: <String, String>{
          'PETWISE_HOST': '0.0.0.0',
          'PETWISE_ENV': 'production',
          'PETWISE_QUESTIONNAIRE_VERSION': '3',
          'PETWISE_SCORING_VERSION': '4',
          'PETWISE_STORAGE_DRIVER': 'postgres',
          'PETWISE_STORAGE_PATH': '/srv/petwise/data',
          'PETWISE_MATCH_RESULT_RETENTION_DAYS': '14',
          'PETWISE_MATCH_RESULT_MAX_RECORDS': '500',
          'DATABASE_URL': 'postgres://petwise:secret@db:5432/petwise',
        },
      );

      expect(config.host, '0.0.0.0');
      expect(config.port, 9090);
      expect(config.environment, RuntimeEnvironment.production);
      expect(config.logLevel, LogLevel.debug);
      expect(config.questionnaireVersion, 3);
      expect(config.scoringVersion, 4);
      expect(config.catalogVersion, 1);
      expect(config.storagePath, '/srv/petwise/data');
      expect(config.storageDriver, StorageDriver.postgres);
      expect(config.matchResultRetentionDays, 14);
      expect(config.maxStoredMatchResults, 500);
      expect(config.databaseUrl, 'postgres://petwise:secret@db:5432/petwise');
      expect(config.exposeErrorDetails, isFalse);
    });

    test('defaults to development-safe values', () {
      final config = RuntimeConfig.fromArgs(const <String>[]);

      expect(config.host, '127.0.0.1');
      expect(config.port, 8080);
      expect(config.environment, RuntimeEnvironment.development);
      expect(config.questionnaireVersion, 1);
      expect(config.scoringVersion, 2);
      expect(config.catalogVersion, 1);
      expect(config.storagePath, 'backend/storage');
      expect(config.storageDriver, StorageDriver.file);
      expect(config.matchResultRetentionDays, 30);
      expect(config.maxStoredMatchResults, 2000);
      expect(config.databaseUrl, isEmpty);
      expect(config.exposeErrorDetails, isTrue);
    });
  });
}
