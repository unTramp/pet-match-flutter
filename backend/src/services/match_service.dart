import 'dart:math';

import '../contracts/match_contracts.dart';
import '../domain/spec_models.dart';
import '../repositories/breed_repository.dart';
import '../repositories/match_result_repository.dart';
import '../repositories/scoring_config_repository.dart';
import 'match_explanation_builder.dart';
import 'media_service.dart';

class MatchService {
  MatchService(
    this._matcher, {
    required int questionnaireVersion,
    required BreedRepository breedRepository,
    required MatchResultRepository matchResultRepository,
    required ScoringConfigRepository scoringConfigRepository,
    required MediaService mediaService,
    MatchExplanationBuilder? explanationBuilder,
  }) : _questionnaireVersion = questionnaireVersion,
       _breedRepository = breedRepository,
       _matchResultRepository = matchResultRepository,
       _scoringConfigRepository = scoringConfigRepository,
       _mediaService = mediaService,
       _explanationBuilder =
           explanationBuilder ?? const MatchExplanationBuilder();

  final MatchScoringEngine _matcher;
  final int _questionnaireVersion;
  final BreedRepository _breedRepository;
  final MatchResultRepository _matchResultRepository;
  final ScoringConfigRepository _scoringConfigRepository;
  final MediaService _mediaService;
  final MatchExplanationBuilder _explanationBuilder;
  static final Random _idRandom = Random.secure();

  Future<Map<String, dynamic>> previewMatch(
    Map<String, dynamic> requestBody,
  ) async {
    final request = MatchPreviewRequest.fromJson(requestBody);
    final scoringConfig = _scoringConfigRepository.getActiveConfig();
    final scoringVersion = _scoringConfigRepository.getActiveVersion();
    final validationErrors = _validateRequest(
      request,
      expectedVersion: _questionnaireVersion,
    );
    if (validationErrors.isNotEmpty) {
      throw MatchPreviewValidationError(validationErrors);
    }

    final results = _matcher.rank(request.userProfile);
    if (results.isEmpty) {
      const refusal = MatchRefusalResponse(
        code: 'no_breeds_for_pet_type',
        message: 'No breeds available for the selected pet type.',
        externalMessage: 'No breeds available for the selected pet type.',
      );
      final response =
          MatchResultResponse(
            resultId: _generateResultId(),
            storedAt: DateTime.now().toUtc().toIso8601String(),
            questionnaireVersion: request.questionnaireVersion,
            scoringVersion: scoringVersion,
            userProfile: request.userProfile,
            topMatch: null,
            alternatives: const <AlternativeBreedResponse>[],
            compatibility: const CompatibilityViewResponse(
              status: 'ready',
              riskLevel: 'high',
              summary: 'No breeds available for the selected pet type.',
              compatible: false,
              insights: <String>[],
              requirementHighlights: <String>[],
              hardReasons: <CompatibilityReasonResponse>[
                CompatibilityReasonResponse(
                  code: 'no_breeds_for_pet_type',
                  severity: 'hard',
                  message: 'No breeds available for the selected pet type.',
                ),
              ],
              risks: <CompatibilityReasonResponse>[],
              refusal: CompatibilityRefusalResponse(
                externalMessage:
                    'No breeds available for the selected pet type.',
              ),
              suggestions: <CompatibilitySuggestionResponse>[],
            ),
            refusal: refusal,
          ).toJson();

      await _matchResultRepository.save(response);
      return response;
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
    final explanation = _explanationBuilder.build(
      breedJson: topBreed,
      matchResult: topResult,
      scoringConfig: scoringConfig,
    );
    final compatibility = _buildCompatibilityView(
      topResult: topResult,
      topBreed: topBreed,
      explanation: explanation,
      alternatives: results.skip(1).take(3).toList(growable: false),
      scoringConfig: scoringConfig,
    );

    final response =
        MatchResultResponse(
          resultId: _generateResultId(),
          storedAt: DateTime.now().toUtc().toIso8601String(),
          questionnaireVersion: request.questionnaireVersion,
          scoringVersion: scoringVersion,
          userProfile: request.userProfile,
          topMatch: RankedBreedResponse(
            breedId: topBreed['breedId'] as String,
            name: topBreed['name'] as String,
            matchPercent: topResult.matchPercent,
            label: label,
            summary: explanation.summary,
            warning: _effectiveWarning(
              topResult: topResult,
              explanation: explanation,
              scoringConfig: scoringConfig,
            ),
            strongMatches: explanation.strongMatches,
            weakMatches: explanation.weakMatches,
          ),
          alternatives: alternatives,
          compatibility: compatibility,
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

  CompatibilityViewResponse _buildCompatibilityView({
    required MatchResult topResult,
    required Map<String, dynamic> topBreed,
    required MatchExplanation explanation,
    required List<MatchResult> alternatives,
    required ScoringConfig scoringConfig,
  }) {
    final hardReasons = topResult.triggeredCapReasons
        .map(
          (reasonCode) => CompatibilityReasonResponse(
            code: reasonCode,
            severity: 'hard',
            message: scoringConfig.capReasonMessages[reasonCode] ?? reasonCode,
          ),
        )
        .toList(growable: false);

    final risks = _buildRiskReasons(
      topResult: topResult,
      explanation: explanation,
      scoringConfig: scoringConfig,
    );
    final compatible = hardReasons.isEmpty;
    final topSuggestions = alternatives
        .map((result) => _buildCompatibilitySuggestion(result))
        .toList(growable: false);

    return CompatibilityViewResponse(
      status: 'ready',
      breedId: topBreed['breedId'] as String,
      breedName: topBreed['name'] as String,
      imageUrl: topBreed['imageUrl'] as String?,
      storyAvatarUrl: _mediaService.resolveStoryAvatarUrl(
        topBreed['storyAvatarUrl'] as String?,
      ),
      riskLevel: _resolveRiskLevel(
        matchPercent: topResult.matchPercent,
        compatible: compatible,
        hasRisks: risks.isNotEmpty,
      ),
      score: topResult.matchPercent,
      summary: explanation.summary,
      compatible: compatible,
      attributes: _readAttributes(topBreed),
      insights: explanation.strongMatches,
      requirementHighlights: explanation.weakMatches,
      hardReasons: hardReasons,
      risks: risks,
      suggestions: topSuggestions,
    );
  }

  List<CompatibilityReasonResponse> _buildRiskReasons({
    required MatchResult topResult,
    required MatchExplanation explanation,
    required ScoringConfig scoringConfig,
  }) {
    final risks = <CompatibilityReasonResponse>[];
    final seenMessages = <String>{};
    final hasHardReasons = topResult.triggeredCapReasons.isNotEmpty;

    final warning = explanation.warning;
    if (!hasHardReasons && warning != null) {
      risks.add(
        CompatibilityReasonResponse(
          code: 'match_warning',
          severity: 'risk',
          message: warning,
        ),
      );
      seenMessages.add(warning);
    }

    for (final reasonCode in topResult.triggeredProfileReasons) {
      final message =
          reasonCode == scoringConfig.profileConflictReasonCode
              ? scoringConfig.profileConflictMessage
              : reasonCode;
      if (!seenMessages.add(message)) {
        continue;
      }
      risks.add(
        CompatibilityReasonResponse(
          code: reasonCode,
          severity: 'risk',
          message: message,
        ),
      );
    }

    return risks;
  }

  String? _effectiveWarning({
    required MatchResult topResult,
    required MatchExplanation explanation,
    required ScoringConfig scoringConfig,
  }) {
    if (explanation.warning case final warning?) {
      return warning;
    }
    if (topResult.triggeredProfileReasons.contains(
      scoringConfig.profileConflictReasonCode,
    )) {
      return scoringConfig.profileConflictMessage;
    }
    return null;
  }

  CompatibilitySuggestionResponse _buildCompatibilitySuggestion(
    MatchResult result,
  ) {
    final breed = _breedRepository.getBreedById(result.breedId);
    final summary =
        (breed?['content'] as Map<String, dynamic>?)?['summaryShort']
            as String?;

    return CompatibilitySuggestionResponse(
      breedId: result.breedId,
      breedName: breed?['name'] as String? ?? result.breedId,
      riskLevel: _resolveRiskLevel(
        matchPercent: result.matchPercent,
        compatible: result.triggeredCapReasons.isEmpty,
        hasRisks: result.contributions.any((item) => item.penalty > 0),
      ),
      score: result.matchPercent,
      summary: summary,
      imageUrl: breed?['imageUrl'] as String?,
      storyAvatarUrl: _mediaService.resolveStoryAvatarUrl(
        breed?['storyAvatarUrl'] as String?,
      ),
      attributes: _readAttributes(breed),
    );
  }

  Map<String, int>? _readAttributes(Map<String, dynamic>? breed) {
    final raw = breed?['attributes'];
    if (raw is! Map<String, dynamic>) return null;

    final attributes = <String, int>{};
    for (final entry in raw.entries) {
      final value = entry.value;
      if (value is num) {
        attributes[entry.key] = value.toInt();
      }
    }
    return attributes.isEmpty ? null : attributes;
  }

  String _resolveRiskLevel({
    required int matchPercent,
    required bool compatible,
    required bool hasRisks,
  }) {
    if (!compatible || matchPercent < 70) {
      return 'high';
    }
    if (hasRisks || matchPercent < 85) {
      return 'medium';
    }
    return 'low';
  }

  String _generateResultId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final randomSuffix =
        List<String>.generate(
          8,
          (_) => _idRandom.nextInt(256).toRadixString(16).padLeft(2, '0'),
          growable: false,
        ).join();
    return 'match_${timestamp}_$randomSuffix';
  }

  List<String> _validateRequest(
    MatchPreviewRequest request, {
    required int expectedVersion,
  }) {
    final errors = <String>[];

    if (request.questionnaireVersion != expectedVersion) {
      errors.add(
        'Questionnaire version mismatch: payload=${request.questionnaireVersion}, expected=$expectedVersion',
      );
    }

    if (request.userProfile.isEmpty) {
      errors.add('userProfile must not be empty');
      return errors;
    }

    final priorities = request.userProfile['priorities'];
    if (priorities != null &&
        (priorities is! List || priorities.any((item) => item is! String))) {
      errors.add('userProfile.priorities must be a list of strings');
    }

    final sizePreference = request.userProfile['sizePreference'];
    if (sizePreference != null &&
        (sizePreference is! List ||
            sizePreference.any((item) => item is! num))) {
      errors.add('userProfile.sizePreference must be a list of integers');
    }

    final criticalContext = request.userProfile['criticalContext'];
    if (criticalContext != null && criticalContext is! Map<String, dynamic>) {
      errors.add('userProfile.criticalContext must be an object');
    }

    if (criticalContext is Map<String, dynamic>) {
      for (final key in const <String>[
        'livesInApartment',
        'hasYoungChildren',
        'hasOtherPets',
      ]) {
        final value = criticalContext[key];
        if (value != null && value is! bool) {
          errors.add('userProfile.criticalContext.$key must be a boolean');
        }
      }
    }

    return errors;
  }
}

class MatchPreviewValidationError implements Exception {
  const MatchPreviewValidationError(this.messages);

  final List<String> messages;

  @override
  String toString() => 'MatchPreviewValidationError(${messages.join('; ')})';
}
