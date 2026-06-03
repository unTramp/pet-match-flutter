import 'dart:io';

import '../src/config/runtime_config.dart';
import '../src/infra/logging/app_logger.dart';
import '../src/app_server.dart';

Future<void> main(List<String> args) async {
  final runtimeConfig = RuntimeConfig.fromArgs(
    args,
    environment: Platform.environment,
  );
  final logger = AppLogger(
    level: runtimeConfig.logLevel,
    serviceName: 'petwise-backend',
  );
  final server = PetWiseAppServer.bootstrap(
    runtimeConfig: runtimeConfig,
    logger: logger,
  );
  final httpServer = await server.start(
    address:
        InternetAddress.tryParse(runtimeConfig.host) ?? InternetAddress.anyIPv4,
    port: runtimeConfig.port,
  );

  logger.info(
    'server.ready',
    fields: <String, Object?>{
      'url': 'http://${httpServer.address.address}:${httpServer.port}',
    },
  );

  Future<void> shutdown(String signalName) async {
    logger.info(
      'server.shutdown',
      fields: <String, Object?>{'signal': signalName},
    );
    await httpServer.close(force: true);
    exit(0);
  }

  ProcessSignal.sigint.watch().listen((_) => shutdown('sigint'));
  ProcessSignal.sigterm.watch().listen((_) => shutdown('sigterm'));
}
