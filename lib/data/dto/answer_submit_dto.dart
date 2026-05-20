class AnswerSubmitDto {
  const AnswerSubmitDto({
    required this.questionId,
    this.optionId,
    this.optionIds,
    this.rawValueText,
    this.selectedValue,
  });

  final int questionId;
  final int? optionId;
  final List<int>? optionIds;
  final String? rawValueText;
  final Map<String, dynamic>? selectedValue;

  Map<String, dynamic> toJson() => {
    'question_id': questionId,
    if (optionId != null) 'option_id': optionId,
    if (optionIds != null) 'option_ids': optionIds,
    if (rawValueText != null) 'raw_value_text': rawValueText,
    if (selectedValue != null) 'selected_value': selectedValue,
  };
}
