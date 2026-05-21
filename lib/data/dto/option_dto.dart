class OptionDto {
  const OptionDto({
    required this.id,
    required this.code,
    required this.label,
    this.sortOrder = 0,
  });

  factory OptionDto.fromJson(Map<String, dynamic> json) => OptionDto(
    id: (json['id'] as num).toInt(),
    code: json['code'] as String,
    label: json['label'] as String,
    sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
  );

  final int id;
  final String code;
  final String label;
  final int sortOrder;
}
