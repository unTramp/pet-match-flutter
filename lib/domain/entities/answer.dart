import 'package:equatable/equatable.dart';

/// Sealed-класс ответа пользователя. UI собирает один из подтипов на основе
/// типа вопроса и передаёт в `SubmitAnswer`. Это устраняет проверки на null
/// в `AnswerSubmitDto` (option_id vs option_ids vs selected_value).
sealed class UserAnswer extends Equatable {
  const UserAnswer({required this.questionId});

  final int questionId;

  @override
  List<Object?> get props => [questionId];
}

final class SingleAnswer extends UserAnswer {
  const SingleAnswer({required super.questionId, required this.optionId});

  final int optionId;

  @override
  List<Object?> get props => [...super.props, optionId];
}

final class MultipleAnswer extends UserAnswer {
  const MultipleAnswer({required super.questionId, required this.optionIds});

  final Set<int> optionIds;

  @override
  List<Object?> get props => [...super.props, optionIds];
}

final class DynamicAnswer extends UserAnswer {
  const DynamicAnswer({
    required super.questionId,
    required this.code,
    required this.label,
    this.sourceType,
  });

  final String code;
  final String label;
  final String? sourceType;

  @override
  List<Object?> get props => [...super.props, code, label, sourceType];
}
