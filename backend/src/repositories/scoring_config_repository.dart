import '../domain/spec_models.dart';

abstract interface class ScoringConfigRepository {
  ScoringConfig getActiveConfig();

  List<Map<String, dynamic>> getLabels();

  int getActiveVersion();
}
