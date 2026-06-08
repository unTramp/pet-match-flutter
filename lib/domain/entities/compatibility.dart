import 'package:equatable/equatable.dart';

import 'breed_attributes.dart';

enum CompatibilityStatus { processing, ready, skipped, failed, unknown }

/// Уровень риска для рекомендации в целом.
/// Cервер шлёт строки 'low' / 'medium' / 'high' — маппер парсит.
enum CompatibilityRisk { low, medium, high, unknown }

/// Severity для конкретной причины. `hard` — обязательная (дисквалифицирует),
/// `risk` — мягкая (стоит учесть).
enum ReasonSeverity { hard, risk }

class CompatibilityReason extends Equatable {
  const CompatibilityReason({
    required this.message,
    required this.severity,
    this.code,
  });

  final String message;
  final ReasonSeverity severity;
  final String? code;

  @override
  List<Object?> get props => [message, severity, code];
}

class CompatibilityRefusal extends Equatable {
  const CompatibilityRefusal({this.title, this.message});

  final String? title;
  final String? message;

  @override
  List<Object?> get props => [title, message];
}

class CompatibilitySuggestion extends Equatable {
  const CompatibilitySuggestion({
    required this.breedId,
    required this.breedName,
    this.score,
    this.risk = CompatibilityRisk.unknown,
    this.summary,
    this.imageUrl,
    this.storyAvatarUrl,
    this.attributes,
  });

  final String breedId;
  final String breedName;
  final double? score;
  final CompatibilityRisk risk;
  final String? summary;
  final String? imageUrl;
  final String? storyAvatarUrl;
  final BreedAttributes? attributes;

  @override
  List<Object?> get props => [
    breedId,
    breedName,
    score,
    risk,
    summary,
    imageUrl,
    storyAvatarUrl,
    attributes,
  ];
}

class Compatibility extends Equatable {
  const Compatibility({
    required this.status,
    this.breedId,
    this.breedName,
    this.imageUrl,
    this.storyAvatarUrl,
    this.score,
    this.risk = CompatibilityRisk.unknown,
    this.compatible,
    this.summary,
    this.insights = const [],
    this.requirementHighlights = const [],
    this.hardReasons = const [],
    this.risks = const [],
    this.refusal,
    this.suggestions = const [],
    this.attributes,
  });

  final CompatibilityStatus status;
  final String? breedId;
  final String? breedName;
  final String? imageUrl;
  final String? storyAvatarUrl;
  final double? score;
  final CompatibilityRisk risk;
  final bool? compatible;
  final String? summary;
  final List<String> insights;
  final List<String> requirementHighlights;
  final List<CompatibilityReason> hardReasons;
  final List<CompatibilityReason> risks;
  final CompatibilityRefusal? refusal;
  final List<CompatibilitySuggestion> suggestions;
  final BreedAttributes? attributes;

  bool get isReady =>
      status == CompatibilityStatus.ready ||
      status == CompatibilityStatus.skipped;

  @override
  List<Object?> get props => [
    status,
    breedId,
    breedName,
    imageUrl,
    storyAvatarUrl,
    score,
    risk,
    compatible,
    summary,
    insights,
    requirementHighlights,
    hardReasons,
    risks,
    refusal,
    suggestions,
    attributes,
  ];
}
