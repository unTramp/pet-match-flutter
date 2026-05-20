import 'package:equatable/equatable.dart';

import 'option.dart';

/// Базовый sealed-класс вопроса. Конкретные подтипы — для каждого `question_type`,
/// который встречается в API. Это даёт exhaustive switch в UI: если добавить
/// новый тип и забыть обработать в presentation — будет ошибка компиляции,
/// а не падение в рантайме.
sealed class Question extends Equatable {
  const Question({
    required this.id,
    required this.title,
    this.helpText,
    this.isOptional = false,
  });

  final int id;
  final String title;
  final String? helpText;
  final bool isOptional;

  @override
  List<Object?> get props => [id, title, helpText, isOptional];
}

final class SingleChoiceQuestion extends Question {
  const SingleChoiceQuestion({
    required super.id,
    required super.title,
    required this.options,
    super.helpText,
    super.isOptional,
  });

  final List<QuestionOption> options;

  @override
  List<Object?> get props => [...super.props, options];
}

final class MultipleChoiceQuestion extends Question {
  const MultipleChoiceQuestion({
    required super.id,
    required super.title,
    required this.options,
    this.exclusiveOptionCodes = const {},
    super.helpText,
    super.isOptional,
  });

  final List<QuestionOption> options;

  /// Коды опций, которые нельзя комбинировать с другими (бэкенд enforces).
  /// Например, "Нет питомцев" нельзя выбрать вместе с "Собака".
  final Set<String> exclusiveOptionCodes;

  @override
  List<Object?> get props => [...super.props, options, exclusiveOptionCodes];
}

final class DynamicOptionsQuestion extends Question {
  const DynamicOptionsQuestion({
    required super.id,
    required super.title,
    super.helpText,
    super.isOptional,
  });
}
