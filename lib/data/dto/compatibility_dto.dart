class CompatibilitySuggestionDto {
  const CompatibilitySuggestionDto({
    required this.breedId,
    required this.breedName,
    this.breedCode,
    this.riskLevel,
    this.score,
    this.summary,
    this.imageUrl,
  });

  factory CompatibilitySuggestionDto.fromJson(Map<String, dynamic> json) =>
      CompatibilitySuggestionDto(
        breedId: (json['breed_id'] as num).toInt(),
        breedCode: json['breed_code'] as String?,
        breedName: json['breed_name'] as String,
        riskLevel: json['risk_level'] as String?,
        score: (json['score'] as num?)?.toDouble(),
        summary: json['summary'] as String?,
        imageUrl: json['image_url'] as String?,
      );

  final int breedId;
  final String? breedCode;
  final String breedName;
  final String? riskLevel;
  final double? score;
  final String? summary;
  final String? imageUrl;
}

class CompatibilityDto {
  const CompatibilityDto({
    required this.status,
    this.breedId,
    this.breedCode,
    this.breedName,
    this.imageUrl,
    this.riskLevel,
    this.score,
    this.summary,
    this.insights = const [],
    this.suggestions = const [],
  });

  factory CompatibilityDto.fromJson(
    Map<String, dynamic> json,
  ) => CompatibilityDto(
    status: json['status'] as String,
    breedId: (json['breed_id'] as num?)?.toInt(),
    breedCode: json['breed_code'] as String?,
    breedName: json['breed_name'] as String?,
    imageUrl: json['image_url'] as String?,
    riskLevel: json['risk_level'] as String?,
    score: (json['score'] as num?)?.toDouble(),
    summary: json['summary'] as String?,
    insights: (json['insights'] as List<dynamic>? ?? const []).cast<String>(),
    suggestions: (json['suggestions'] as List<dynamic>? ?? const [])
        .map(
          (e) => CompatibilitySuggestionDto.fromJson(e as Map<String, dynamic>),
        )
        .toList(growable: false),
  );

  final String status;
  final int? breedId;
  final String? breedCode;
  final String? breedName;
  final String? imageUrl;
  final String? riskLevel;
  final double? score;
  final String? summary;
  final List<String> insights;
  final List<CompatibilitySuggestionDto> suggestions;
}
