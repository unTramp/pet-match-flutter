class PetWiseQuestionOptionDto {
  const PetWiseQuestionOptionDto({
    required this.id,
    required this.label,
  });

  factory PetWiseQuestionOptionDto.fromJson(Map<String, dynamic> json) =>
      PetWiseQuestionOptionDto(
        id: json['id'] as String,
        label: json['label'] as String,
      );

  final String id;
  final String label;
}

class PetWiseQuestionDto {
  const PetWiseQuestionDto({
    required this.id,
    required this.order,
    required this.kind,
    required this.isRequired,
    required this.title,
    required this.options,
    this.description,
    this.maxSelections,
  });

  factory PetWiseQuestionDto.fromJson(Map<String, dynamic> json) =>
      PetWiseQuestionDto(
        id: json['id'] as String,
        order: (json['order'] as num).toInt(),
        kind: json['kind'] as String,
        isRequired: json['required'] as bool? ?? false,
        title: json['title'] as String,
        description: json['description'] as String?,
        maxSelections: (json['maxSelections'] as num?)?.toInt(),
        options:
            (json['options'] as List<dynamic>? ?? const [])
                .map(
                  (item) => PetWiseQuestionOptionDto.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList(growable: false),
      );

  final String id;
  final int order;
  final String kind;
  final bool isRequired;
  final String title;
  final String? description;
  final int? maxSelections;
  final List<PetWiseQuestionOptionDto> options;
}

class PetWiseQuestionnaireDefinitionDto {
  const PetWiseQuestionnaireDefinitionDto({
    required this.questionnaireVersion,
    required this.questions,
  });

  factory PetWiseQuestionnaireDefinitionDto.fromJson(Map<String, dynamic> json) {
    return PetWiseQuestionnaireDefinitionDto(
      questionnaireVersion: (json['questionnaireVersion'] as num).toInt(),
      questions:
          (json['questions'] as List<dynamic>? ?? const [])
              .map(
                (item) => PetWiseQuestionDto.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(growable: false),
    );
  }

  final int questionnaireVersion;
  final List<PetWiseQuestionDto> questions;
}
