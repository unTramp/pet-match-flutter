class DynamicOptionDto {
  const DynamicOptionDto({
    required this.code,
    required this.label,
    this.sourceType,
    this.sortOrder = 0,
  });

  factory DynamicOptionDto.fromJson(Map<String, dynamic> json) =>
      DynamicOptionDto(
        sourceType: json['source_type'] as String?,
        code: json['code'] as String,
        label: json['label'] as String,
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      );

  final String? sourceType;
  final String code;
  final String label;
  final int sortOrder;

  Map<String, dynamic> toJson() => {
    if (sourceType != null) 'source_type': sourceType,
    'code': code,
    'label': label,
    'sort_order': sortOrder,
  };
}

class DynamicOptionListDto {
  const DynamicOptionListDto({required this.questionId, this.items = const []});

  factory DynamicOptionListDto.fromJson(Map<String, dynamic> json) =>
      DynamicOptionListDto(
        questionId: (json['question_id'] as num).toInt(),
        items: (json['items'] as List<dynamic>? ?? const [])
            .map((e) => DynamicOptionDto.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
      );

  final int questionId;
  final List<DynamicOptionDto> items;

  Map<String, dynamic> toJson() => {
    'question_id': questionId,
    'items': items.map((i) => i.toJson()).toList(),
  };
}
