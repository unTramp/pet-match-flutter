import 'dart:math';

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

  MatchExplanation build(Map<String, dynamic> breedJson) {
    final content = Map<String, dynamic>.from(
      breedJson['content'] as Map<String, dynamic>? ?? const {},
    );

    return MatchExplanation(
      summary:
          content['summaryShort'] as String? ??
          'Reference explanation is not available for this breed yet.',
      warning: _firstOrNull(content['watchouts']),
      strongMatches: _takeStrings(content['strengths'], 4),
      weakMatches: _takeStrings(content['watchouts'], 3),
    );
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
