import 'package:equatable/equatable.dart';

import '../../../core/failures.dart';
import '../../../domain/entities/compatibility.dart';
import '../../../domain/entities/option.dart';
import '../../../domain/entities/progress.dart';
import '../../../domain/entities/question.dart';

sealed class QuestionnaireState extends Equatable {
  const QuestionnaireState();

  @override
  List<Object?> get props => const [];
}

final class QuestionnaireInitial extends QuestionnaireState {
  const QuestionnaireInitial();
}

final class QuestionnaireLoading extends QuestionnaireState {
  const QuestionnaireLoading();
}

/// Активный вопрос. Холдит локальный выбор пользователя и — для
/// `DynamicOptionsQuestion` — текущий список подгруженных опций.
final class QuestionnaireQuestion extends QuestionnaireState {
  const QuestionnaireQuestion({
    required this.question,
    required this.progress,
    this.selectedOptionIds = const {},
    this.dynamicSelected,
    this.isSubmitting = false,
  });

  final Question question;
  final Progress progress;
  final Set<int> selectedOptionIds;
  final DynamicOption? dynamicSelected;
  final bool isSubmitting;

  bool get canSubmit => switch (question) {
    SingleChoiceQuestion() => selectedOptionIds.length == 1,
    MultipleChoiceQuestion() => selectedOptionIds.isNotEmpty,
    DynamicOptionsQuestion() => dynamicSelected != null,
    // Неизвестный тип — отправить нечего, пользователь может только пропустить
    // (если вопрос optional) или обновить приложение.
    UnknownQuestion() => false,
  };

  QuestionnaireQuestion copyWith({
    Set<int>? selectedOptionIds,
    DynamicOption? dynamicSelected,
    bool? isSubmitting,
  }) {
    return QuestionnaireQuestion(
      question: question,
      progress: progress,
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
      dynamicSelected: dynamicSelected ?? this.dynamicSelected,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
    question,
    progress,
    selectedOptionIds,
    dynamicSelected,
    isSubmitting,
  ];
}

/// Совместимость готова, UI делает redirect на /result.
final class QuestionnaireResultReady extends QuestionnaireState {
  const QuestionnaireResultReady({required this.compatibility});

  final Compatibility compatibility;

  @override
  List<Object?> get props => [compatibility];
}

final class QuestionnaireError extends QuestionnaireState {
  const QuestionnaireError({required this.failure, required this.canRetry});

  final AppFailure failure;
  final bool canRetry;

  @override
  List<Object?> get props => [failure, canRetry];
}
