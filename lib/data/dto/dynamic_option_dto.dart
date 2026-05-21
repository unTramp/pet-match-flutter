class DynamicOptionDto {
  const DynamicOptionDto({
    required this.code,
    required this.label,
    this.sourceType,
  });

  factory DynamicOptionDto.fromJson(Map<String, dynamic> json) =>
      DynamicOptionDto(
        sourceType: json['source_type'] as String?,
        code: json['code'] as String,
        label: json['label'] as String,
      );

  final String? sourceType;
  final String code;
  final String label;
}

class DynamicOptionListDto {
  const DynamicOptionListDto({this.items = const []});

  factory DynamicOptionListDto.fromJson(Map<String, dynamic> json) =>
      DynamicOptionListDto(
        items: (json['items'] as List<dynamic>? ?? const [])
            .map((e) => DynamicOptionDto.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
      );

  final List<DynamicOptionDto> items;
}
