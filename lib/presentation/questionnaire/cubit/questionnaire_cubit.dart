import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/failures.dart';
import '../../../core/logger.dart';
import '../../../domain/entities/answer.dart';
import '../../../domain/entities/option.dart';
import '../../../domain/entities/question.dart';
import '../../../domain/entities/session.dart';
import '../../../domain/usecases/skip_question.dart';
import '../../../domain/usecases/start_session.dart';
import '../../../domain/usecases/submit_answer.dart';
import 'questionnaire_state.dart';

/// Центральный Cubit анкеты. Управляет переходами Question → Loading → Question
/// и финальным Completed, после которого UI делает redirect на /analyzing.
class QuestionnaireCubit extends Cubit<QuestionnaireState> {
  QuestionnaireCubit(this._startSession, this._submitAnswer, this._skipQuestion)
    : super(const QuestionnaireInitial());

  final StartSession _startSession;
  final SubmitAnswer _submitAnswer;
  final SkipQuestion _skipQuestion;

  int? _userId;
  final List<QuestionnaireQuestion> _history = [];
  QuestionnaireQuestion? _pendingPrevious;

  /// Публичный геттер для DynamicOptionsWidget (он сам вызывает usecase через DI,
  /// но ему нужен userId текущей сессии).
  int get userId => _userId ?? 0;
  bool get canGoBack => _history.isNotEmpty;

  /// Стартует или возобновляет анкету. `_userId` сохраняется для последующих
  /// submit/skip-вызовов.
  Future<void> start() async {
    _history.clear();
    _pendingPrevious = null;
    emit(const QuestionnaireLoading());
    try {
      final session = await _startSession();
      _userId = session.userId;
      _emitFromSession(session);
    } on AppFailure catch (f) {
      appLogger.w('start() failed: $f');
      emit(QuestionnaireError(failure: f, canRetry: true));
    }
  }

  /// Инициализация из уже предзагруженной сессии (например, prefetch на welcome),
  /// чтобы не показывать промежуточный полноэкранный loading.
  void startWithSession(Session session) {
    _history.clear();
    _pendingPrevious = null;
    _userId = session.userId;
    _emitFromSession(session);
  }

  void selectSingle(int optionId) {
    final s = state;
    if (s is! QuestionnaireQuestion) return;
    emit(s.copyWith(selectedOptionIds: {optionId}));
  }

  void toggleMulti(int optionId) {
    final s = state;
    if (s is! QuestionnaireQuestion) return;
    final question = s.question;
    if (question is! MultipleChoiceQuestion) return;

    final exclusive = question.exclusiveOptionCodes;
    final tapped = question.options.firstWhere(
      (o) => o.id == optionId,
      orElse: () => question.options.first,
    );
    final tappedIsExclusive = exclusive.contains(tapped.code);

    final current = Set<int>.from(s.selectedOptionIds);

    if (current.contains(optionId)) {
      // Toggle off: просто убираем — никаких других правил не нужно.
      current.remove(optionId);
      emit(s.copyWith(selectedOptionIds: current));
      return;
    }

    if (tappedIsExclusive) {
      // Кликнули по exclusive-опции → она вытесняет всё остальное.
      emit(s.copyWith(selectedOptionIds: {optionId}));
      return;
    }

    // Кликнули по обычной опции → убираем все ранее выбранные exclusive
    // и добавляем эту.
    current.removeWhere((id) {
      final opt = question.options.firstWhere(
        (o) => o.id == id,
        orElse: () => question.options.first,
      );
      return exclusive.contains(opt.code);
    });
    current.add(optionId);
    emit(s.copyWith(selectedOptionIds: current));
  }

  void selectDynamic(DynamicOption option) {
    final s = state;
    if (s is! QuestionnaireQuestion) return;
    emit(s.copyWith(dynamicSelected: option));
  }

  Future<void> submit() async {
    final s = state;
    if (s is! QuestionnaireQuestion || !s.canSubmit || s.isSubmitting) return;
    final userId = _userId;
    if (userId == null) return;

    final answer = _buildAnswer(s);
    if (answer == null) return;

    _pendingPrevious = s;
    emit(s.copyWith(isSubmitting: true));
    try {
      final session = await _submitAnswer(userId: userId, answer: answer);
      if (isClosed) return;
      _emitFromSession(session);
    } on AppFailure catch (f) {
      if (isClosed) return;
      _pendingPrevious = null;
      appLogger.w('submit() failed: $f');
      emit(QuestionnaireError(failure: f, canRetry: true));
    }
  }

  Future<void> skipCurrent() async {
    final s = state;
    if (s is! QuestionnaireQuestion || s.isSubmitting) return;
    if (!s.question.isOptional) return;
    final userId = _userId;
    if (userId == null) return;

    _pendingPrevious = s;
    emit(s.copyWith(isSubmitting: true));
    try {
      final session = await _skipQuestion(
        userId: userId,
        questionId: s.question.id,
      );
      if (isClosed) return;
      _emitFromSession(session);
    } on AppFailure catch (f) {
      if (isClosed) return;
      _pendingPrevious = null;
      appLogger.w('skipCurrent() failed: $f');
      emit(QuestionnaireError(failure: f, canRetry: true));
    }
  }

  void goBack() {
    // Защита от race: пока submit/skip в полёте, back игнорируем.
    final current = state;
    if (current is QuestionnaireQuestion && current.isSubmitting) return;
    if (current is QuestionnaireLoading) return;
    if (_history.isEmpty) return;
    _pendingPrevious = null;
    final previous = _history.removeLast();
    emit(previous);
  }

  /// Повторяет последнее действие, которое привело к ошибке. По умолчанию —
  /// `start()` (если ошибка случилась до загрузки первого вопроса, _userId
  /// ещё null). Иначе пытаемся снова загрузить текущую сессию через start —
  /// бэкенд вернёт session под тем же external_id.
  Future<void> retry() async {
    await start();
  }

  UserAnswer? _buildAnswer(QuestionnaireQuestion s) {
    return switch (s.question) {
      SingleChoiceQuestion(:final id) => SingleAnswer(
        questionId: id,
        optionId: s.selectedOptionIds.first,
      ),
      MultipleChoiceQuestion(:final id) => MultipleAnswer(
        questionId: id,
        optionIds: s.selectedOptionIds.toList(),
      ),
      DynamicOptionsQuestion(:final id) => () {
        final selected = s.dynamicSelected;
        if (selected == null) return null;
        return DynamicAnswer(
          questionId: id,
          code: selected.code,
          label: selected.label,
          sourceType: selected.sourceType,
        );
      }(),
      // canSubmit для UnknownQuestion = false, сюда не должны попадать,
      // но возвращаем null чтобы submit() сделал ранний return.
      UnknownQuestion() => null,
    };
  }

  void _emitFromSession(Session session) {
    if (isClosed) return;
    final previous = _pendingPrevious;
    _pendingPrevious = null;
    if (previous != null) {
      _history.add(previous);
    }
    final next = session.nextQuestion;
    if (next == null) {
      emit(QuestionnaireCompleted(userId: session.userId));
      return;
    }
    emit(QuestionnaireQuestion(question: next, progress: session.progress));
  }
}
