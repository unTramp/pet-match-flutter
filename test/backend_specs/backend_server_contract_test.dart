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

    test(
      'POST /questionnaire/profile returns profileDiagnostics for contradictory answers',
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
                'selectedOptionIds': <String>['dog'],
              },
              <String, dynamic>{
                'questionId': 'home_type',
                'selectedOptionIds': <String>['apartment'],
              },
              <String, dynamic>{
                'questionId': 'daily_activity',
                'selectedOptionIds': <String>['120_plus'],
              },
              <String, dynamic>{
                'questionId': 'alone_time',
                'selectedOptionIds': <String>['4_8'],
              },
              <String, dynamic>{
                'questionId': 'children',
                'selectedOptionIds': <String>['no'],
              },
              <String, dynamic>{
                'questionId': 'other_pets',
                'selectedOptionIds': <String>['none'],
              },
              <String, dynamic>{
                'questionId': 'grooming_tolerance',
                'selectedOptionIds': <String>['minimal'],
              },
              <String, dynamic>{
                'questionId': 'shedding_tolerance',
                'selectedOptionIds': <String>['a_little_ok'],
              },
              <String, dynamic>{
                'questionId': 'preferred_size',
                'selectedOptionIds': <String>['large'],
              },
            ],
          },
        );

        expect(response.$1, HttpStatus.ok);
        final userProfile = response.$2['userProfile'] as Map<String, dynamic>;
        final diagnostics =
            userProfile['profileDiagnostics'] as Map<String, dynamic>;
        expect(diagnostics['hasConflicts'], isTrue);
        expect(diagnostics['conflicts'], isA<List<dynamic>>());
      },
    );

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
      expect(response.$2['scoringVersion'], 2);
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
          'compatibility',
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
      final compatibility =
          response.$2['compatibility'] as Map<String, dynamic>;
      expect(
        compatibility.keys,
        containsAll(<String>[
          'status',
          'breed_id',
          'breed_name',
          'risk_level',
          'score',
          'summary',
          'compatible',
          'story_avatar_url',
          'insights',
          'requirement_highlights',
          'hard_reasons',
          'risks',
          'suggestions',
        ]),
      );
      expect(compatibility['status'], 'ready');
      expect(compatibility['insights'], isA<List<dynamic>>());
    });

    test(
      'POST /match/preview returns 400 for invalid userProfile payload',
      () async {
        final response = await _requestJson(
          client,
          server,
          method: 'POST',
          path: '/match/preview',
          body: <String, dynamic>{
            'questionnaireVersion': 1,
            'userProfile': <String, dynamic>{
              'petType': 'dog',
              'priorities': 'quiet',
              'criticalContext': 'bad-shape',
            },
          },
        );

        expect(response.$1, HttpStatus.badRequest);
        expect(response.$2['error'], 'Invalid match preview request');
        expect(response.$2['details'], isA<List<dynamic>>());
      },
    );

    test(
      'POST /match/preview ignores normalization-only conflicts and surfaces true contradictions',
      () async {
        final profileResponse = await _requestJson(
          client,
          server,
          method: 'POST',
          path: '/questionnaire/profile',
          body: <String, dynamic>{
            'questionnaireVersion': 1,
            'answers': <Map<String, dynamic>>[
              <String, dynamic>{
                'questionId': 'pet_type',
                'selectedOptionIds': <String>['dog'],
              },
              <String, dynamic>{
                'questionId': 'home_type',
                'selectedOptionIds': <String>['apartment'],
              },
              <String, dynamic>{
                'questionId': 'daily_activity',
                'selectedOptionIds': <String>['120_plus'],
              },
              <String, dynamic>{
                'questionId': 'alone_time',
                'selectedOptionIds': <String>['4_8'],
              },
              <String, dynamic>{
                'questionId': 'children',
                'selectedOptionIds': <String>['no'],
              },
              <String, dynamic>{
                'questionId': 'other_pets',
                'selectedOptionIds': <String>['none'],
              },
              <String, dynamic>{
                'questionId': 'grooming_tolerance',
                'selectedOptionIds': <String>['minimal'],
              },
              <String, dynamic>{
                'questionId': 'shedding_tolerance',
                'selectedOptionIds': <String>['a_little_ok'],
              },
              <String, dynamic>{
                'questionId': 'preferred_size',
                'selectedOptionIds': <String>['large'],
              },
            ],
          },
        );

        final profileDiagnostics =
            (profileResponse.$2['userProfile']
                    as Map<String, dynamic>)['profileDiagnostics']
                as Map<String, dynamic>;
        final conflictCodes =
            (profileDiagnostics['conflicts'] as List<dynamic>)
                .map((item) => (item as Map<String, dynamic>)['code'])
                .toList();
        expect(conflictCodes, contains('value_capped_by_constraint'));
        expect(conflictCodes, contains('no_allowed_values_overlap'));

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
        final compatibility =
            response.$2['compatibility'] as Map<String, dynamic>;
        final risks = compatibility['risks'] as List<dynamic>;
        final hardReasons = compatibility['hard_reasons'] as List<dynamic>;
        final requirementHighlights =
            (compatibility['requirement_highlights'] as List<dynamic>)
                .cast<String>();
        expect(
          risks.any(
            (item) =>
                (item as Map<String, dynamic>)['code'] ==
                'contradictory_answers',
          ),
          isTrue,
        );
        final riskMessages =
            risks
                .map((item) => (item as Map<String, dynamic>)['message'])
                .whereType<String>()
                .toSet();
        final hardReasonMessages =
            hardReasons
                .map((item) => (item as Map<String, dynamic>)['message'])
                .whereType<String>()
                .toSet();
        expect(riskMessages.intersection(hardReasonMessages), isEmpty);
        expect(
          riskMessages.intersection(requirementHighlights.toSet()),
          isEmpty,
        );
      },
    );

    test(
      'POST /match/preview returns refusal payload for unsupported petType',
      () async {
        final response = await _requestJson(
          client,
          server,
          method: 'POST',
          path: '/match/preview',
          body: <String, dynamic>{
            'questionnaireVersion': 1,
            'userProfile': <String, dynamic>{
              'petType': 'cat',
              'priorities': <String>[],
            },
          },
        );

        expect(response.$1, HttpStatus.ok);
        expect(response.$2['topMatch'], isNull);
        expect(response.$2['alternatives'], isEmpty);
        expect(response.$2['refusal'], <String, dynamic>{
          'code': 'no_breeds_for_pet_type',
          'message': 'No breeds available for the selected pet type.',
          'title': null,
          'externalMessage': 'No breeds available for the selected pet type.',
        });
        expect(response.$2['compatibility'], <String, dynamic>{
          'status': 'ready',
          'breed_id': null,
          'breed_name': null,
          'image_url': null,
          'story_avatar_url': null,
          'risk_level': 'high',
          'score': null,
          'summary': 'No breeds available for the selected pet type.',
          'compatible': false,
          'insights': <dynamic>[],
          'requirement_highlights': <dynamic>[],
          'hard_reasons': <Map<String, dynamic>>[
            <String, dynamic>{
              'code': 'no_breeds_for_pet_type',
              'severity': 'hard',
              'message': 'No breeds available for the selected pet type.',
            },
          ],
          'risks': <dynamic>[],
          'refusal': <String, dynamic>{
            'title': null,
            'external_message':
                'No breeds available for the selected pet type.',
          },
          'suggestions': <dynamic>[],
        });
      },
    );

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
