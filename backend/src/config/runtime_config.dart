import '../spec_paths.dart';

enum RuntimeEnvironment { development, staging, production }

enum LogLevel { debug, info, warn, error }

enum StorageDriver { file, postgres }

class RuntimeConfig {
  const RuntimeConfig({
    required this.host,
    required this.port,
    required this.environment,
    required this.logLevel,
    required this.questionnaireVersion,
    required this.scoringVersion,
    required this.catalogVersion,
    required this.storagePath,
    required this.storageDriver,
    required this.databaseUrl,
    required this.exposeErrorDetails,
    required this.matchResultRetentionDays,
    required this.maxStoredMatchResults,
  });

  factory RuntimeConfig.fromArgs(
    List<String> args, {
    Map<String, String>? environment,
  }) {
    final env = environment ?? const <String, String>{};
    final runtimeEnvironment = _parseEnvironment(
      _readArgValue(args, '--env') ?? env['PETWISE_ENV'],
    );
    final exposeErrorDetails =
        _parseBool(
          _readArgValue(args, '--expose-error-details') ??
              env['PETWISE_EXPOSE_ERROR_DETAILS'],
        ) ??
        (runtimeEnvironment != RuntimeEnvironment.production);

    return RuntimeConfig(
      host: _readArgValue(args, '--host') ?? env['PETWISE_HOST'] ?? '127.0.0.1',
      port:
          int.tryParse(
            _readArgValue(args, '--port') ?? env['PETWISE_PORT'] ?? '',
          ) ??
          8080,
      environment: runtimeEnvironment,
      logLevel: _parseLogLevel(
        _readArgValue(args, '--log-level') ?? env['PETWISE_LOG_LEVEL'],
      ),
      questionnaireVersion:
          int.tryParse(
            _readArgValue(args, '--questionnaire-version') ??
                env['PETWISE_QUESTIONNAIRE_VERSION'] ??
                '',
          ) ??
          1,
      scoringVersion:
          int.tryParse(
            _readArgValue(args, '--scoring-version') ??
                env['PETWISE_SCORING_VERSION'] ??
                '',
          ) ??
          2,
      catalogVersion:
          int.tryParse(
            _readArgValue(args, '--catalog-version') ??
                env['PETWISE_CATALOG_VERSION'] ??
                '',
          ) ??
          1,
      storagePath:
          _readArgValue(args, '--storage-path') ??
          env['PETWISE_STORAGE_PATH'] ??
          'backend/storage',
      storageDriver: _parseStorageDriver(
        _readArgValue(args, '--storage-driver') ??
            env['PETWISE_STORAGE_DRIVER'],
      ),
      databaseUrl:
          _readArgValue(args, '--database-url') ?? env['DATABASE_URL'] ?? '',
      exposeErrorDetails: exposeErrorDetails,
      matchResultRetentionDays:
          int.tryParse(
            _readArgValue(args, '--match-result-retention-days') ??
                env['PETWISE_MATCH_RESULT_RETENTION_DAYS'] ??
                '',
          ) ??
          30,
      maxStoredMatchResults:
          int.tryParse(
            _readArgValue(args, '--max-stored-match-results') ??
                env['PETWISE_MATCH_RESULT_MAX_RECORDS'] ??
                '',
          ) ??
          2000,
    );
  }

  final String host;
  final int port;
  final RuntimeEnvironment environment;
  final LogLevel logLevel;
  final int questionnaireVersion;
  final int scoringVersion;
  final int catalogVersion;
  final String storagePath;
  final StorageDriver storageDriver;
  final String databaseUrl;
  final bool exposeErrorDetails;
  final int matchResultRetentionDays;
  final int maxStoredMatchResults;

  BackendSpecPaths get specPaths => BackendSpecPaths.fromVersions(
    questionnaireVersion: questionnaireVersion,
    scoringVersion: scoringVersion,
    catalogVersion: catalogVersion,
  );

  String get environmentName => environment.name;

  Map<String, dynamic> toLogFields() {
    return <String, dynamic>{
      'host': host,
      'port': port,
      'environment': environment.name,
      'logLevel': logLevel.name,
      'questionnaireVersion': questionnaireVersion,
      'scoringVersion': scoringVersion,
      'catalogVersion': catalogVersion,
      'storagePath': storagePath,
      'storageDriver': storageDriver.name,
      'databaseUrlConfigured': databaseUrl.isNotEmpty,
      'exposeErrorDetails': exposeErrorDetails,
      'matchResultRetentionDays': matchResultRetentionDays,
      'maxStoredMatchResults': maxStoredMatchResults,
    };
  }
}

String? _readArgValue(List<String> args, String flag) {
  final index = args.indexOf(flag);
  if (index == -1 || index + 1 >= args.length) {
    return null;
  }
  return args[index + 1];
}

RuntimeEnvironment _parseEnvironment(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case 'production':
    case 'prod':
      return RuntimeEnvironment.production;
    case 'staging':
      return RuntimeEnvironment.staging;
    default:
      return RuntimeEnvironment.development;
  }
}

LogLevel _parseLogLevel(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case 'debug':
      return LogLevel.debug;
    case 'warn':
    case 'warning':
      return LogLevel.warn;
    case 'error':
      return LogLevel.error;
    default:
      return LogLevel.info;
  }
}

StorageDriver _parseStorageDriver(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case 'postgres':
    case 'postgresql':
      return StorageDriver.postgres;
    default:
      return StorageDriver.file;
  }
}

bool? _parseBool(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case '1':
    case 'true':
    case 'yes':
    case 'on':
      return true;
    case '0':
    case 'false':
    case 'no':
    case 'off':
      return false;
    default:
      return null;
  }
}
