import '../config/runtime_config.dart';

class HealthService {
  HealthService({
    required RuntimeConfig runtimeConfig,
    required DateTime startedAt,
    required int questionnaireVersion,
    required int scoringVersion,
  }) : _runtimeConfig = runtimeConfig,
       _startedAt = startedAt,
       _questionnaireVersion = questionnaireVersion,
       _scoringVersion = scoringVersion;

  final RuntimeConfig _runtimeConfig;
  final DateTime _startedAt;
  final int _questionnaireVersion;
  final int _scoringVersion;

  Map<String, dynamic> health() {
    return <String, dynamic>{
      'status': 'ok',
      'service': 'petwise-backend',
      'environment': _runtimeConfig.environmentName,
      'uptimeSeconds': DateTime.now().difference(_startedAt).inSeconds,
    };
  }

  Map<String, dynamic> readiness() {
    return <String, dynamic>{
      'status': 'ready',
      'service': 'petwise-backend',
      'environment': _runtimeConfig.environmentName,
      'questionnaireVersion': _questionnaireVersion,
      'scoringVersion': _scoringVersion,
    };
  }
}
