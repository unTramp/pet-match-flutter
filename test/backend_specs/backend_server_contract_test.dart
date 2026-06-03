import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../backend/src/app_server.dart';
import '../../backend/src/config/runtime_config.dart';
import '../../backend/src/infra/logging/app_logger.dart';

void main() {
  group('reference backend server contracts', () {
    late PetWiseAppServer appServer;
    late HttpServer server;
    late HttpClient client;
    late Directory storageDir;

    setUpAll(() async {
      storageDir = Directory.systemTemp.createTempSync(
        'petwise_backend_contract_',
      );
      appServer = PetWiseAppServer.bootstrap(
        runtimeConfig: RuntimeConfig(
          host: '127.0.0.1',
          port: 8080,
          environment: RuntimeEnvironment.development,
          logLevel: LogLevel.info,
          questionnaireVersion: 1,
          scoringVersion: 1,
          catalogVersion: 1,
          storagePath: storageDir.path,
          storageDriver: StorageDriver.file,
          databaseUrl: '',
          exposeErrorDetails: true,
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

    test('POST /questionnaire/profile returns contract shape', () async {
      final payload = _groupedAnswersPayload(
        _loadJson(
          'docs/backend/examples/answers.apartment_quiet_beginner.json',
        ),
      );

      final response = await _requestJson(
        client,
        server,
        method: 'POST',
        path: '/questionnaire/profile',
        body: payload,
      );

      expect(response.$1, HttpStatus.ok);
      expect(
        response.$2.keys,
        containsAll(<String>['questionnaireVersion', 'userProfile']),
      );

      final userProfile = response.$2['userProfile'] as Map<String, dynamic>;
      expect(
        userProfile.keys,
        containsAll(<String>['petType', 'priorities', 'criticalContext']),
      );
      expect(
        (userProfile['criticalContext'] as Map<String, dynamic>).keys,
        containsAll(<String>[
          'livesInApartment',
          'hasYoungChildren',
          'hasOtherPets',
        ]),
      );
    });

    test('GET /ready returns readiness contract shape', () async {
      final response = await _requestJson(
        client,
        server,
        method: 'GET',
        path: '/ready',
      );

      expect(response.$1, HttpStatus.ok);
      expect(
        response.$2.keys,
        containsAll(<String>[
          'status',
          'service',
          'environment',
          'questionnaireVersion',
          'scoringVersion',
        ]),
      );
      expect(response.$2['status'], 'ready');
      expect(response.$2['questionnaireVersion'], 1);
      expect(response.$2['scoringVersion'], 1);
    });

    test(
      'POST /questionnaire/profile returns 400 for invalid answers',
      () async {
        final response = await _requestJson(
          client,
          server,
          method: 'POST',
          path: '/questionnaire/profile',
          body: <String, dynamic>{
            'questionnaireVersion': 1,
            'answers': <Map<String, dynamic>>[
              <String, dynamic>{
                'questionId': 'pet_type',
                'selectedOptionIds': <String>['dog', 'cat'],
              },
            ],
          },
        );

        expect(response.$1, HttpStatus.badRequest);
        expect(response.$2['error'], 'Invalid questionnaire answers');
        expect(response.$2['details'], isA<List<dynamic>>());
      },
    );

    test('POST /match/preview returns contract shape', () async {
      final buildPayload = _groupedAnswersPayload(
        _loadJson('docs/backend/examples/answers.family_friendly.json'),
      );
      final profileResponse = await _requestJson(
        client,
        server,
        method: 'POST',
        path: '/questionnaire/profile',
        body: buildPayload,
      );

      final response = await _requestJson(
        client,
        server,
        method: 'POST',
        path: '/match/preview',
        body: <String, dynamic>{
          'questionnaireVersion': 1,
          'userProfile': profileResponse.$2['userProfile'],
        },
      );

      expect(response.$1, HttpStatus.ok);
      expect(
        response.$2.keys,
        containsAll(<String>[
          'resultId',
          'storedAt',
          'questionnaireVersion',
          'scoringVersion',
          'userProfile',
          'topMatch',
          'alternatives',
        ]),
      );

      final topMatch = response.$2['topMatch'] as Map<String, dynamic>;
      expect(
        topMatch.keys,
        containsAll(<String>[
          'breedId',
          'name',
          'matchPercent',
          'label',
          'summary',
          'strongMatches',
          'weakMatches',
        ]),
      );
      expect(response.$2['alternatives'], isA<List<dynamic>>());
    });

    test('GET /matches/{resultId} returns persisted match result', () async {
      final buildPayload = _groupedAnswersPayload(
        _loadJson(
          'docs/backend/examples/answers.apartment_quiet_beginner.json',
        ),
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

      final resultId = matchResponse.$2['resultId'] as String;
      final response = await _requestJson(
        client,
        server,
        method: 'GET',
        path: '/matches/$resultId',
      );

      expect(response.$1, HttpStatus.ok);
      expect(response.$2['resultId'], resultId);
      expect(response.$2['storedAt'], isA<String>());
    });

    test('GET /breeds/{breedId} returns 404 for unknown breed', () async {
      final response = await _requestJson(
        client,
        server,
        method: 'GET',
        path: '/breeds/not_real',
      );

      expect(response.$1, HttpStatus.notFound);
      expect(response.$2['error'], 'Breed not found');
    });

    test('GET /matches/{resultId} returns 404 for unknown result', () async {
      final response = await _requestJson(
        client,
        server,
        method: 'GET',
        path: '/matches/not_real',
      );

      expect(response.$1, HttpStatus.notFound);
      expect(response.$2['error'], 'Match result not found');
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

Map<String, dynamic> _loadJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

Map<String, dynamic> _groupedAnswersPayload(Map<String, dynamic> flatPayload) {
  final grouped = <String, List<String>>{};
  for (final raw in flatPayload['answers'] as List<dynamic>) {
    final answer = raw as Map<String, dynamic>;
    grouped.putIfAbsent(answer['questionId'] as String, () => <String>[])
      ..add(answer['optionId'] as String);
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
