import 'dart:math';

import '../domain/spec_models.dart';

class MatchExplanation {
  const MatchExplanation({
    required this.summary,
    required this.warning,
    required this.strongMatches,
    required this.weakMatches,
  });

  final String summary;
  final String? warning;
  final List<String> strongMatches;
  final List<String> weakMatches;
}

class MatchExplanationBuilder {
  const MatchExplanationBuilder();

  MatchExplanation build({
    required Map<String, dynamic> breedJson,
    required MatchResult matchResult,
    required ScoringConfig scoringConfig,
  }) {
    final content = Map<String, dynamic>.from(
      breedJson['content'] as Map<String, dynamic>? ?? const {},
    );
    final strongMatches = _strongMatches(matchResult, scoringConfig);
    final weakMatches = _weakMatches(matchResult, scoringConfig);
    final warning = _warning(
      matchResult: matchResult,
      scoringConfig: scoringConfig,
      content: content,
    );

    return MatchExplanation(
      summary:
          content['summaryShort'] as String? ??
          'Reference explanation is not available for this breed yet.',
      warning: warning,
      strongMatches:
          strongMatches.isEmpty
              ? _takeStrings(content['strengths'], 4)
              : strongMatches,
      weakMatches:
          weakMatches.isEmpty ? _takeStrings(content['watchouts'], 3) : weakMatches,
    );
  }

  String? _warning({
    required MatchResult matchResult,
    required ScoringConfig scoringConfig,
    required Map<String, dynamic> content,
  }) {
    for (final reason in matchResult.triggeredCapReasons) {
      final message = scoringConfig.capReasonMessages[reason];
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    return _firstOrNull(content['watchouts']);
  }

  List<String> _strongMatches(
    MatchResult matchResult,
    ScoringConfig scoringConfig,
  ) {
    final contributions =
        matchResult.contributions
        .where((contribution) => contribution.penalty == 0)
        .toList()
          ..sort((left, right) => right.weight.compareTo(left.weight));
    return _labels(contributions.take(max(0, 3)), scoringConfig);
  }

  List<String> _weakMatches(
    MatchResult matchResult,
    ScoringConfig scoringConfig,
  ) {
    final contributions =
        matchResult.contributions
        .where((contribution) => contribution.penalty > 0)
        .toList()
          ..sort((left, right) {
            final byPenalty = right.weightedPenalty.compareTo(
              left.weightedPenalty,
            );
            if (byPenalty != 0) {
              return byPenalty;
            }
            return right.weight.compareTo(left.weight);
          });
    return _labels(contributions.take(max(0, 3)), scoringConfig);
  }

  List<String> _labels(
    Iterable<FieldContribution> contributions,
    ScoringConfig scoringConfig,
  ) {
    return contributions
        .map(
          (contribution) =>
              scoringConfig.fieldLabels[contribution.field] ?? contribution.field,
        )
        .toSet()
        .take(3)
        .toList();
  }

  String? _firstOrNull(Object? raw) {
    final values =
        raw is List ? raw.whereType<String>().toList() : const <String>[];
    return values.isEmpty ? null : values.first;
  }

  List<String> _takeStrings(Object? raw, int maxItems) {
    final values =
        raw is List ? raw.whereType<String>().toList() : const <String>[];
    return values.take(max(0, maxItems)).toList();
  }
}
