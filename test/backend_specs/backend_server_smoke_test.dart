import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../backend/src/app_server.dart';
import '../../backend/src/config/runtime_config.dart';
import '../../backend/src/infra/logging/app_logger.dart';

void main() {
  group('reference backend server', () {
    late PetWiseAppServer appServer;
    late HttpServer server;
    late HttpClient client;
    late Directory storageDir;

    setUpAll(() async {
      storageDir = Directory.systemTemp.createTempSync(
        'petwise_backend_smoke_',
      );
      appServer = PetWiseAppServer.bootstrap(
        runtimeConfig: RuntimeConfig(
          host: '127.0.0.1',
          port: 8080,
          environment: RuntimeEnvironment.development,
          logLevel: LogLevel.info,
          questionnaireVersion: 1,
          scoringVersion: 2,
          catalogVersion: 1,
          storagePath: storageDir.path,
          storageDriver: StorageDriver.file,
          databaseUrl: '',
          exposeErrorDetails: true,
          matchResultRetentionDays: 30,
          maxStoredMatchResults: 2000,
        ),
        logger: AppLogger(level: LogLevel.info, serviceName: 'petwise-backend'),
      );
      server = await appServer.start(
        address: InternetAddress.loopbackIPv4,
        port: 0,
      );
      client = HttpClient();
    });

    tearDownAll(() async {
      client.close(force: true);
      await server.close(force: true);
      if (storageDir.existsSync()) {
        storageDir.deleteSync(recursive: true);
      }
    });

    test('GET /health returns service health payload', () async {
      final response = await _requestJson(
        client,
        server,
        method: 'GET',
        path: '/health',
      );

      expect(response.$1, HttpStatus.ok);
      expect(response.$2['status'], 'ok');
      expect(response.$2['service'], 'petwise-backend');
    });

    test(
      'GET /questionnaire/definition returns active questionnaire',
      () async {
        final response = await _requestJson(
          client,
          server,
          method: 'GET',
          path: '/questionnaire/definition',
        );

        expect(response.$1, HttpStatus.ok);
        expect(response.$2['questionnaireVersion'], 1);
        expect((response.$2['questions'] as List<dynamic>).length, 13);
      },
    );

    test('POST /questionnaire/profile builds a profile', () async {
      final payload = _groupedAnswersPayload(
        jsonDecode(
              File(
                'docs/backend/examples/answers.apartment_quiet_beginner.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>,
      );

      final response = await _requestJson(
        client,
        server,
        method: 'POST',
        path: '/questionnaire/profile',
        body: payload,
      );

      expect(response.$1, HttpStatus.ok);
      final userProfile = response.$2['userProfile'] as Map<String, dynamic>;
      expect(userProfile['petType'], 'dog');
      expect(userProfile['sizePreference'], <dynamic>[3]);
    });

    test('POST /match/preview returns ranked result payload', () async {
      final buildPayload = _groupedAnswersPayload(
        jsonDecode(
              File(
                'docs/backend/examples/answers.apartment_quiet_beginner.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>,
      );
      final profileResponse = await _requestJson(
        client,
        server,
        method: 'POST',
        path: '/questionnaire/profile',
        body: buildPayload,
      );

      final matchResponse = await _requestJson(
        client,
        server,
        method: 'POST',
        path: '/match/preview',
        body: <String, dynamic>{
          'questionnaireVersion': 1,
          'userProfile': profileResponse.$2['userProfile'],
        },
      );

      expect(matchResponse.$1, HttpStatus.ok);
      final topMatch = matchResponse.$2['topMatch'] as Map<String, dynamic>;
      expect(topMatch['breedId'], 'whippet');
      final compatibility =
          matchResponse.$2['compatibility'] as Map<String, dynamic>;
      expect(compatibility['breed_id'], 'whippet');
      expect(compatibility['status'], 'ready');
      expect(compatibility['insights'], isA<List<dynamic>>());
      final resultId = matchResponse.$2['resultId'] as String;

      final savedResponse = await _requestJson(
        client,
        server,
        method: 'GET',
        path: '/matches/$resultId',
      );

      expect(savedResponse.$1, HttpStatus.ok);
      expect(savedResponse.$2['resultId'], resultId);
      expect(savedResponse.$2['storedAt'], isA<String>());
    });

    test('GET /breeds/{breedId} returns breed details', () async {
      final response = await _requestJson(
        client,
        server,
        method: 'GET',
        path: '/breeds/whippet',
      );

      expect(response.$1, HttpStatus.ok);
      expect(response.$2['breedId'], 'whippet');
    });
  });
}

Future<(int, Map<String, dynamic>)> _requestJson(
  HttpClient client,
  HttpServer server, {
  required String method,
  required String path,
  Map<String, dynamic>? body,
}) async {
  final request = await client.open(
    method,
    server.address.address,
    server.port,
    path,
  );
  request.headers.contentType = ContentType.json;
  if (body != null) {
    request.write(jsonEncode(body));
  }

  final response = await request.close();
  final text = await utf8.decoder.bind(response).join();
  return (
    response.statusCode,
    text.trim().isEmpty
        ? <String, dynamic>{}
        : jsonDecode(text) as Map<String, dynamic>,
  );
}

Map<String, dynamic> _groupedAnswersPayload(Map<String, dynamic> flatPayload) {
  final grouped = <String, List<String>>{};
  for (final raw in flatPayload['answers'] as List<dynamic>) {
    final answer = raw as Map<String, dynamic>;
    grouped
        .putIfAbsent(answer['questionId'] as String, () => <String>[])
        .add(answer['optionId'] as String);
  }

  return <String, dynamic>{
    'questionnaireVersion': flatPayload['questionnaireVersion'],
    'answers':
        grouped.entries
            .map(
              (entry) => <String, dynamic>{
                'questionId': entry.key,
                'selectedOptionIds': entry.value,
              },
            )
            .toList(),
  };
}
