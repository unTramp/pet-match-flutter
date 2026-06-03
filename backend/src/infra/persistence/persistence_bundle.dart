import '../../domain/profile_builder.dart';
import '../../repositories/breed_repository.dart';
import '../../repositories/match_result_repository.dart';
import '../../repositories/questionnaire_repository.dart';
import '../../repositories/scoring_config_repository.dart';

class PersistenceBundle {
  const PersistenceBundle({
    required this.questionnaireRepository,
    required this.breedRepository,
    required this.scoringConfigRepository,
    required this.matchResultRepository,
    required this.profileBuilderDefinition,
  });

  final QuestionnaireRepository questionnaireRepository;
  final BreedRepository breedRepository;
  final ScoringConfigRepository scoringConfigRepository;
  final MatchResultRepository matchResultRepository;
  final ProfileBuilderDefinition profileBuilderDefinition;
}
