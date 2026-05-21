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

/// Причина (hard) или потенциальный риск (risk) — оба используют один shape
/// в OpenAPI (`CompatibilityReasonRead`).
class CompatibilityReasonDto {
  const CompatibilityReasonDto({
    required this.code,
    required this.severity,
    required this.message,
  });

  factory CompatibilityReasonDto.fromJson(Map<String, dynamic> json) =>
      CompatibilityReasonDto(
        code: json['code'] as String? ?? '',
        severity: json['severity'] as String? ?? 'risk',
        message: json['message'] as String? ?? '',
      );

  final String code;
  final String severity; // 'hard' | 'risk'
  final String message;
}

/// Развёрнутая аргументация при отказе. Игнорируем `internal_reason` —
/// это поле для логирования на бэке, не для пользователя.
class CompatibilityRefusalDto {
  const CompatibilityRefusalDto({this.title, this.externalMessage});

  factory CompatibilityRefusalDto.fromJson(Map<String, dynamic> json) =>
      CompatibilityRefusalDto(
        title: json['title'] as String?,
        externalMessage: json['external_message'] as String?,
      );

  final String? title;
  final String? externalMessage;
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
    this.compatible,
    this.hardFailCount = 0,
    this.insights = const [],
    this.requirementHighlights = const [],
    this.hardReasons = const [],
    this.risks = const [],
    this.refusal,
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
    compatible: json['compatible'] as bool?,
    hardFailCount: (json['hard_fail_count'] as num?)?.toInt() ?? 0,
    insights: (json['insights'] as List<dynamic>? ?? const []).cast<String>(),
    requirementHighlights:
        (json['requirement_highlights'] as List<dynamic>? ?? const [])
            .cast<String>(),
    hardReasons: (json['hard_reasons'] as List<dynamic>? ?? const [])
        .map((e) => CompatibilityReasonDto.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    risks: (json['risks'] as List<dynamic>? ?? const [])
        .map((e) => CompatibilityReasonDto.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    refusal:
        json['refusal'] is Map<String, dynamic>
            ? CompatibilityRefusalDto.fromJson(
              json['refusal'] as Map<String, dynamic>,
            )
            : null,
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
  final bool? compatible;
  final int hardFailCount;
  final List<String> insights;
  final List<String> requirementHighlights;
  final List<CompatibilityReasonDto> hardReasons;
  final List<CompatibilityReasonDto> risks;
  final CompatibilityRefusalDto? refusal;
  final List<CompatibilitySuggestionDto> suggestions;
}
