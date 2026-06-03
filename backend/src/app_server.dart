import 'dart:convert';
import 'dart:io';

import 'config/runtime_config.dart';
import 'domain/matcher.dart';
import 'domain/profile_builder.dart';
import 'infra/logging/app_logger.dart';
import 'infra/persistence/persistence_bootstrap.dart';
import 'services/breed_service.dart';
import 'services/health_service.dart';
import 'services/match_service.dart';
import 'services/profile_service.dart';
import 'services/questionnaire_service.dart';
import 'services/stored_match_result_service.dart';

class PetWiseAppServer {
  factory PetWiseAppServer.bootstrap({
    required RuntimeConfig runtimeConfig,
    required AppLogger logger,
  }) {
    final persistence = PersistenceBootstrap.create(
      runtimeConfig: runtimeConfig,
      logger: logger,
    );

    return PetWiseAppServer._(
      runtimeConfig: runtimeConfig,
      logger: logger,
      questionnaireService: QuestionnaireService(
        persistence.questionnaireRepository,
      ),
      profileService: ProfileService(
        QuestionnaireProfileBuilder(persistence.profileBuilderDefinition),
      ),
      matchService: MatchService(
        ReferenceMatcher(
          config: persistence.scoringConfigRepository.getActiveConfig(),
          breeds: persistence.breedRepository.listBreedFixtures(),
        ),
        breedRepository: persistence.breedRepository,
        matchResultRepository: persistence.matchResultRepository,
        scoringConfigRepository: persistence.scoringConfigRepository,
      ),
      breedService: BreedService(persistence.breedRepository),
      storedMatchResultService: StoredMatchResultService(
        persistence.matchResultRepository,
      ),
      healthService: HealthService(
        runtimeConfig: runtimeConfig,
        startedAt: DateTime.now(),
        questionnaireVersion:
            persistence.questionnaireRepository.getActiveVersion(),
        scoringVersion: persistence.scoringConfigRepository.getActiveVersion(),
      ),
    );
  }

  factory PetWiseAppServer({RuntimeConfig? runtimeConfig, AppLogger? logger}) {
    final resolvedRuntimeConfig =
        runtimeConfig ??
        RuntimeConfig.fromArgs(
          const <String>[],
          environment: Platform.environment,
        );
    final resolvedLogger =
        logger ??
        AppLogger(
          level: resolvedRuntimeConfig.logLevel,
          serviceName: 'petwise-backend',
        );
    return PetWiseAppServer.bootstrap(
      runtimeConfig: resolvedRuntimeConfig,
      logger: resolvedLogger,
    );
  }

  PetWiseAppServer._({
    required RuntimeConfig runtimeConfig,
    required AppLogger logger,
    required QuestionnaireService questionnaireService,
    required ProfileService profileService,
    required MatchService matchService,
    required BreedService breedService,
    required StoredMatchResultService storedMatchResultService,
    required HealthService healthService,
  }) : _runtimeConfig = runtimeConfig,
       _logger = logger,
       _questionnaireService = questionnaireService,
       _profileService = profileService,
       _matchService = matchService,
       _breedService = breedService,
       _storedMatchResultService = storedMatchResultService,
       _healthService = healthService;

  final RuntimeConfig _runtimeConfig;
  final AppLogger _logger;
  final QuestionnaireService _questionnaireService;
  final ProfileService _profileService;
  final MatchService _matchService;
  final BreedService _breedService;
  final StoredMatchResultService _storedMatchResultService;
  final HealthService _healthService;

  Future<HttpServer> start({
    required InternetAddress address,
    required int port,
  }) async {
    final server = await HttpServer.bind(address, port);
    _logger.info(
      'server.started',
      fields: <String, Object?>{
        ..._runtimeConfig.toLogFields(),
        'boundAddress': server.address.address,
        'boundPort': server.port,
      },
    );
    server.listen(_handleRequest);
    return server;
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final stopwatch = Stopwatch()..start();
    final requestId = '${DateTime.now().microsecondsSinceEpoch}';
    _ApiResponse apiResponse;

    try {
      apiResponse = await _dispatchRequest(request);
    } on ProfileBuildValidationError catch (error) {
      apiResponse = _ApiResponse(HttpStatus.badRequest, <String, dynamic>{
        'error': 'Invalid questionnaire answers',
        'details': error.messages,
        'requestId': requestId,
      });
    } on FormatException catch (error) {
      apiResponse = _ApiResponse(HttpStatus.badRequest, <String, dynamic>{
        'error': 'Invalid JSON',
        'details': error.message,
        'requestId': requestId,
      });
    } catch (error, stackTrace) {
      _logger.error(
        'request.failed',
        fields: <String, Object?>{
          'requestId': requestId,
          'method': request.method,
          'path': request.uri.path,
        },
        error: error,
        stackTrace: stackTrace,
      );
      apiResponse = _internalServerErrorResponse(requestId, error);
    }

    await _writeJson(
      request.response,
      apiResponse.statusCode,
      apiResponse.payload,
    );

    stopwatch.stop();
    _logger.info(
      'request.completed',
      fields: <String, Object?>{
        'requestId': requestId,
        'method': request.method,
        'path': request.uri.path,
        'statusCode': apiResponse.statusCode,
        'durationMs': stopwatch.elapsedMilliseconds,
      },
    );
  }

  Future<_ApiResponse> _dispatchRequest(HttpRequest request) async {
    final path = request.uri.path;

    if (request.method == 'GET' && path == '/health') {
      return _ApiResponse(HttpStatus.ok, _healthService.health());
    }

    if (request.method == 'GET' && path == '/ready') {
      return _ApiResponse(HttpStatus.ok, _healthService.readiness());
    }

    if (request.method == 'GET' && path == '/questionnaire/definition') {
      return _ApiResponse(HttpStatus.ok, _questionnaireService.getDefinition());
    }

    if (request.method == 'POST' && path == '/questionnaire/profile') {
      final payload = await _readJson(request);
      return _ApiResponse(HttpStatus.ok, _profileService.buildProfile(payload));
    }

    if (request.method == 'POST' && path == '/match/preview') {
      final payload = await _readJson(request);
      return _ApiResponse(
        HttpStatus.ok,
        await _matchService.previewMatch(payload),
      );
    }

    if (request.method == 'GET' && path.startsWith('/breeds/')) {
      final breedId = path.substring('/breeds/'.length);
      final breed = _breedService.getBreed(breedId);
      if (breed == null) {
        return _ApiResponse(HttpStatus.notFound, <String, dynamic>{
          'error': 'Breed not found',
          'breedId': breedId,
        });
      }
      return _ApiResponse(HttpStatus.ok, breed);
    }

    if (request.method == 'GET' && path.startsWith('/matches/')) {
      final resultId = path.substring('/matches/'.length);
      final result = await _storedMatchResultService.getById(resultId);
      if (result == null) {
        return _ApiResponse(HttpStatus.notFound, <String, dynamic>{
          'error': 'Match result not found',
          'resultId': resultId,
        });
      }
      return _ApiResponse(HttpStatus.ok, result);
    }

    return _ApiResponse(HttpStatus.notFound, <String, dynamic>{
      'error': 'Not found',
      'path': path,
    });
  }

  _ApiResponse _internalServerErrorResponse(String requestId, Object error) {
    final payload = <String, dynamic>{
      'error': 'Internal server error',
      'requestId': requestId,
    };
    if (_runtimeConfig.exposeErrorDetails) {
      payload['details'] = '$error';
    }
    return _ApiResponse(HttpStatus.internalServerError, payload);
  }

  Future<Map<String, dynamic>> _readJson(HttpRequest request) async {
    final body = await utf8.decoder.bind(request).join();
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<void> _writeJson(
    HttpResponse response,
    int statusCode,
    Map<String, dynamic> payload,
  ) async {
    response.statusCode = statusCode;
    response.headers.contentType = ContentType.json;
    response.write(const JsonEncoder.withIndent('  ').convert(payload));
    await response.close();
  }
}

class _ApiResponse {
  const _ApiResponse(this.statusCode, this.payload);

  final int statusCode;
  final Map<String, dynamic> payload;
}
