import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/failures.dart';
import '../../../core/logger.dart';
import '../../../domain/entities/answer.dart';
import '../../../domain/entities/option.dart';
import '../../../domain/entities/question.dart';
import '../../../domain/entities/session.dart';
import '../../../domain/usecases/poll_compatibility.dart';
import '../../../domain/usecases/skip_question.dart';
import '../../../domain/usecases/start_session.dart';
import '../../../domain/usecases/submit_answer.dart';
import 'questionnaire_state.dart';

/// Центральный Cubit анкеты. Управляет переходами Question → Question
/// и финальным результатом, после которого UI делает redirect на /result.
///
/// Таймауты сетевых вызовов настроены на уровне Dio (`receiveTimeout`);
/// здесь дополнительный `.timeout()` не вешаем, чтобы не плодить гонки.
class QuestionnaireCubit extends Cubit<QuestionnaireState> {
  QuestionnaireCubit(
    this._startSession,
    this._submitAnswer,
    this._skipQuestion,
    this._pollCompatibility,
  ) : super(const QuestionnaireInitial());

  final StartSession _startSession;
  final SubmitAnswer _submitAnswer;
  final SkipQuestion _skipQuestion;
  final PollCompatibility _pollCompatibility;

  int? _userId;
  _LastAction? _lastAction;

  /// Стартует или возобновляет анкету.
  Future<void> start() async {
    _lastAction = const _StartAction();
    emit(const QuestionnaireLoading());
    await _runSessionOp(_startSession.call);
  }

  /// Инициализация из уже предзагруженной сессии (например, prefetch на welcome),
  /// чтобы не показывать промежуточный полноэкранный loading.
  Future<void> startWithSession(Session session) async {
    _lastAction = const _StartAction();
    _userId = session.userId;
    await _emitFromSession(session);
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

    _lastAction = _SubmitAction(answer);
    emit(s.copyWith(isSubmitting: true));
    await _runSessionOp(
      () => _submitAnswer(userId: userId, answer: answer),
    );
  }

  Future<void> skipCurrent() async {
    final s = state;
    if (s is! QuestionnaireQuestion || s.isSubmitting) return;
    if (!s.question.isOptional) return;
    final userId = _userId;
    if (userId == null) return;

    _lastAction = _SkipAction(s.question.id);
    emit(s.copyWith(isSubmitting: true));
    await _runSessionOp(
      () => _skipQuestion(userId: userId, questionId: s.question.id),
    );
  }

  /// Повторяет последнее действие, которое привело к ошибке. Если ошибка
  /// случилась до первого вызова — диспатчим `start()`. Иначе реально
  /// реплеим submit/skip с теми же аргументами.
  Future<void> retry() async {
    final action = _lastAction;
    final uid = _userId;
    switch (action) {
      case _ResolveCompatibilityAction(:final userId):
        emit(const QuestionnaireAnalyzing());
        await _resolveCompatibility(userId);
      case _SubmitAction(:final answer) when uid != null:
        await _runSessionOp(() => _submitAnswer(userId: uid, answer: answer));
      case _SkipAction(:final questionId) when uid != null:
        await _runSessionOp(
          () => _skipQuestion(userId: uid, questionId: questionId),
        );
      case _StartAction():
      case _SubmitAction():
      case _SkipAction():
      case null:
        await start();
    }
  }

  /// Единый раннер сессионных операций: выполняет [op], при успехе
  /// эмитит следующий state, при ошибке — `QuestionnaireError`.
  Future<void> _runSessionOp(Future<Session> Function() op) async {
    try {
      final session = await op();
      if (isClosed) return;
      _userId = session.userId;
      await _emitFromSession(session);
    } on AppFailure catch (f) {
      if (isClosed) return;
      appLogger.w('Session op failed: $f');
      emit(QuestionnaireError(failure: f, canRetry: true));
    } catch (e, st) {
      if (isClosed) return;
      appLogger.e('Session op unexpected error', error: e, stackTrace: st);
      emit(
        const QuestionnaireError(
          failure: ServerFailure.unexpected(),
          canRetry: true,
        ),
      );
    }
  }

  UserAnswer? _buildAnswer(QuestionnaireQuestion s) {
    return switch (s.question) {
      SingleChoiceQuestion(:final id) => SingleAnswer(
        questionId: id,
        optionId: s.selectedOptionIds.first,
      ),
      MultipleChoiceQuestion(:final id) => MultipleAnswer(
        questionId: id,
        optionIds: Set<int>.unmodifiable(s.selectedOptionIds),
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

  Future<void> _emitFromSession(Session session) async {
    if (isClosed) return;
    final next = session.nextQuestion;
    if (next == null) {
      final ready = session.compatibility;
      if (ready != null && ready.isReady) {
        emit(QuestionnaireResultReady(compatibility: ready));
        return;
      }
      _lastAction = _ResolveCompatibilityAction(session.userId);
      emit(const QuestionnaireAnalyzing());
      await _resolveCompatibility(session.userId);
      return;
    }
    emit(
      QuestionnaireQuestion(
        userId: session.userId,
        question: next,
        progress: session.progress,
      ),
    );
  }

  Future<void> _resolveCompatibility(int userId) async {
    try {
      final compatibility = await _pollCompatibility(userId: userId);
      if (isClosed) return;
      emit(QuestionnaireResultReady(compatibility: compatibility));
    } on AppFailure catch (f) {
      if (isClosed) return;
      emit(QuestionnaireError(failure: f, canRetry: true));
    } catch (e, st) {
      if (isClosed) return;
      appLogger.e(
        '_resolveCompatibility() unexpected error',
        error: e,
        stackTrace: st,
      );
      emit(
        const QuestionnaireError(
          failure: ServerFailure.unexpected(),
          canRetry: true,
        ),
      );
    }
  }
}

sealed class _LastAction {
  const _LastAction();
}

final class _StartAction extends _LastAction {
  const _StartAction();
}

final class _SubmitAction extends _LastAction {
  const _SubmitAction(this.answer);
  final UserAnswer answer;
}

final class _SkipAction extends _LastAction {
  const _SkipAction(this.questionId);
  final int questionId;
}

final class _ResolveCompatibilityAction extends _LastAction {
  const _ResolveCompatibilityAction(this.userId);

  final int userId;
}
