import 'package:equatable/equatable.dart';

enum CompatibilityStatus { processing, ready, failed, unknown }

class CompatibilitySuggestion extends Equatable {
  const CompatibilitySuggestion({
    required this.breedId,
    required this.breedName,
    this.breedCode,
    this.score,
    this.riskLevel,
    this.summary,
    this.imageUrl,
  });

  final int breedId;
  final String breedName;
  final String? breedCode;
  final double? score;
  final String? riskLevel;
  final String? summary;
  final String? imageUrl;

  @override
  List<Object?> get props => [
    breedId,
    breedName,
    breedCode,
    score,
    riskLevel,
    summary,
    imageUrl,
  ];
}

class Compatibility extends Equatable {
  const Compatibility({
    required this.status,
    this.breedId,
    this.breedName,
    this.imageUrl,
    this.score,
    this.riskLevel,
    this.summary,
    this.insights = const [],
    this.suggestions = const [],
  });

  final CompatibilityStatus status;
  final int? breedId;
  final String? breedName;
  final String? imageUrl;
  final double? score;
  final String? riskLevel;
  final String? summary;
  final List<String> insights;
  final List<CompatibilitySuggestion> suggestions;

  bool get isReady => status == CompatibilityStatus.ready;

  @override
  List<Object?> get props => [
    status,
    breedId,
    breedName,
    imageUrl,
    score,
    riskLevel,
    summary,
    insights,
    suggestions,
  ];
}
