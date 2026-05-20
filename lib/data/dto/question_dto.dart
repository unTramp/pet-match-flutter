import 'option_dto.dart';

class QuestionDto {
  const QuestionDto({
    required this.id,
    required this.title,
    required this.questionType,
    this.code,
    this.helpText,
    this.isOptional = false,
    this.sortOrder = 0,
    this.options = const [],
    this.configJson,
  });

  factory QuestionDto.fromJson(Map<String, dynamic> json) => QuestionDto(
    id: (json['id'] as num).toInt(),
    code: json['code'] as String?,
    title: json['title'] as String,
    helpText: json['help_text'] as String?,
    questionType: json['question_type'] as String,
    isOptional: json['is_optional'] as bool? ?? false,
    sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    options: (json['options'] as List<dynamic>? ?? const [])
        .map((e) => OptionDto.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    configJson: json['config_json'] as Map<String, dynamic>?,
  );

  final int id;
  final String? code;
  final String title;
  final String? helpText;
  final String questionType;
  final bool isOptional;
  final int sortOrder;
  final List<OptionDto> options;

  /// Содержит метаданные вопроса: например, `exclusive_option_codes` для
  /// multi-choice (опции, которые нельзя комбинировать с другими),
  /// `visibility_rule`, `options_source` для search_select, и т.д.
  /// Структура свободная — читаем только то, что нужно UI.
  final Map<String, dynamic>? configJson;

  Map<String, dynamic> toJson() => {
    'id': id,
    if (code != null) 'code': code,
    'title': title,
    if (helpText != null) 'help_text': helpText,
    'question_type': questionType,
    'is_optional': isOptional,
    'sort_order': sortOrder,
    'options': options.map((o) => o.toJson()).toList(),
    if (configJson != null) 'config_json': configJson,
  };
}
