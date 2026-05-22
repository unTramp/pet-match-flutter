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

/// Анкета пройдена, бэк считает совместимость. UI показывает отдельный
/// analyzing-экран перед переходом к результату.
final class QuestionnaireAnalyzing extends QuestionnaireState {
  const QuestionnaireAnalyzing();
}

/// Активный вопрос. Холдит локальный выбор пользователя и — для
/// `DynamicOptionsQuestion` — текущий список подгруженных опций.
///
/// `userId` хранится в state, а не как поле Cubit'а: это делает
/// зависимость явной для UI (DynamicOptionsWidget берёт userId из state),
/// и снимает риск дёрнуть запрос до того, как сессия стартовала.
final class QuestionnaireQuestion extends QuestionnaireState {
  const QuestionnaireQuestion({
    required this.userId,
    required this.question,
    required this.progress,
    this.selectedOptionIds = const {},
    this.dynamicSelected,
    this.isSubmitting = false,
  });

  final int userId;
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

  static const Object _unsetDynamicSelected = Object();

  QuestionnaireQuestion copyWith({
    Set<int>? selectedOptionIds,
    Object? dynamicSelected = _unsetDynamicSelected,
    bool? isSubmitting,
  }) {
    return QuestionnaireQuestion(
      userId: userId,
      question: question,
      progress: progress,
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
      dynamicSelected: identical(dynamicSelected, _unsetDynamicSelected)
          ? this.dynamicSelected
          : dynamicSelected as DynamicOption?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
    userId,
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
