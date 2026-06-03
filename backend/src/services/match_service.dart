import '../contracts/match_contracts.dart';
import '../domain/spec_models.dart';
import '../repositories/breed_repository.dart';
import '../repositories/match_result_repository.dart';
import '../repositories/scoring_config_repository.dart';
import 'match_explanation_builder.dart';

class MatchService {
  MatchService(
    this._matcher, {
    required BreedRepository breedRepository,
    required MatchResultRepository matchResultRepository,
    required ScoringConfigRepository scoringConfigRepository,
    MatchExplanationBuilder? explanationBuilder,
  }) : _breedRepository = breedRepository,
       _matchResultRepository = matchResultRepository,
       _scoringConfigRepository = scoringConfigRepository,
       _explanationBuilder =
           explanationBuilder ?? const MatchExplanationBuilder();

  final MatchScoringEngine _matcher;
  final BreedRepository _breedRepository;
  final MatchResultRepository _matchResultRepository;
  final ScoringConfigRepository _scoringConfigRepository;
  final MatchExplanationBuilder _explanationBuilder;

  Future<Map<String, dynamic>> previewMatch(
    Map<String, dynamic> requestBody,
  ) async {
    final request = MatchPreviewRequest.fromJson(requestBody);

    final results = _matcher.rank(request.userProfile);
    if (results.isEmpty) {
      throw StateError('No breeds available for matching.');
    }

    final topResult = results.first;
    final topBreed = _breedRepository.getBreedById(topResult.breedId);
    if (topBreed == null) {
      throw StateError('Top breed not found: ${topResult.breedId}');
    }

    final alternatives =
        results.skip(1).take(3).map((result) {
          final breed = _breedRepository.getBreedById(result.breedId);
          return AlternativeBreedResponse(
            breedId: result.breedId,
            name: breed?['name'] as String? ?? result.breedId,
            matchPercent: result.matchPercent,
          );
        }).toList();

    final label = _resolveLabel(topResult.matchPercent);
    final explanation = _explanationBuilder.build(topBreed);

    final response =
        MatchResultResponse(
          resultId: 'match_${DateTime.now().millisecondsSinceEpoch}',
          storedAt: DateTime.now().toUtc().toIso8601String(),
          questionnaireVersion: request.questionnaireVersion,
          scoringVersion: _scoringConfigRepository.getActiveVersion(),
          userProfile: request.userProfile,
          topMatch: RankedBreedResponse(
            breedId: topBreed['breedId'] as String,
            name: topBreed['name'] as String,
            matchPercent: topResult.matchPercent,
            label: label,
            summary: explanation.summary,
            warning: explanation.warning,
            strongMatches: explanation.strongMatches,
            weakMatches: explanation.weakMatches,
          ),
          alternatives: alternatives,
        ).toJson();

    await _matchResultRepository.save(response);
    return response;
  }

  String _resolveLabel(int matchPercent) {
    final labels = _scoringConfigRepository.getLabels();
    for (final label in labels) {
      final min = (label['min'] as num).toInt();
      if (matchPercent >= min) {
        return label['label'] as String;
      }
    }
    return 'Есть более подходящие варианты';
  }
}
