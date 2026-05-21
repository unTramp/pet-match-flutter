import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/components/ui_card.dart';
import '../../core/design/content/app_strings.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/question.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'cubit/questionnaire_cubit.dart';
import 'cubit/questionnaire_state.dart';
import 'widgets/dynamic_options_widget.dart';
import 'widgets/multiple_choice_widget.dart';
import 'widgets/progress_bar.dart';
import 'widgets/question_footer.dart';
import 'widgets/single_choice_widget.dart';

class QuestionnairePage extends StatelessWidget {
  const QuestionnairePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuestionnaireCubit>(
      create: (_) => sl<QuestionnaireCubit>()..start(),
      child: const _QuestionnaireView(),
    );
  }
}

class _QuestionnaireView extends StatelessWidget {
  const _QuestionnaireView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuestionnaireCubit, QuestionnaireState>(
      listener: (context, state) {
        if (state is QuestionnaireCompleted) {
          context.go('/analyzing', extra: state.userId);
        }
      },
      builder: (context, state) {
        final questionState = state is QuestionnaireQuestion ? state : null;
        final cubit = context.read<QuestionnaireCubit>();
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.questionnaire.appBarTitle),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () async {
                if (questionState != null && cubit.canGoBack) {
                  cubit.goBack();
                  return;
                }
                final shouldExit = await _confirmExit(context);
                if (!context.mounted || !shouldExit) return;
                context.go('/welcome');
              },
            ),
          ),
          bottomNavigationBar:
              questionState == null
                  ? null
                  : _QuestionBottomBar(
                    canSubmit: questionState.canSubmit,
                    onSubmit: cubit.submit,
                    canSkip: questionState.question.isOptional,
                    onSkip: cubit.skipCurrent,
                  ),
          body: SafeArea(
            child: switch (state) {
              QuestionnaireInitial() || QuestionnaireLoading() =>
                LoadingView(message: AppStrings.questionnaire.loading),
              QuestionnaireQuestion() => _QuestionBody(state: state),
              QuestionnaireError(:final failure) => ErrorView(
                failure: failure,
                onRetry: () => context.read<QuestionnaireCubit>().retry(),
              ),
              QuestionnaireCompleted() => const LoadingView(),
            },
          ),
        );
      },
    );
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppStrings.questionnaire.exitDialogTitle),
            content: Text(AppStrings.questionnaire.exitDialogMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppStrings.questionnaire.exitDialogCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(AppStrings.questionnaire.exitDialogConfirm),
              ),
            ],
          ),
    );
    return result ?? false;
  }
}

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({required this.state});

  final QuestionnaireQuestion state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = state.question;
    final cubit = context.read<QuestionnaireCubit>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProgressBar(progress: state.progress),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UiCard(
                    showShadow: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.title,
                          style: theme.textTheme.headlineMedium,
                        ),
                        if (question.helpText != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            question.helpText!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (question is MultipleChoiceQuestion &&
                            question.helpText == null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            AppStrings.questionnaire.multiSelectHint,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.9,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  switch (question) {
                    SingleChoiceQuestion(:final options) => SingleChoiceWidget(
                      options: options,
                      selectedId:
                          state.selectedOptionIds.isEmpty
                              ? null
                              : state.selectedOptionIds.first,
                      onSelect: cubit.selectSingle,
                    ),
                    MultipleChoiceQuestion(:final options) =>
                      MultipleChoiceWidget(
                        options: options,
                        selectedIds: state.selectedOptionIds,
                        onToggle: cubit.toggleMulti,
                      ),
                    DynamicOptionsQuestion(:final id) => DynamicOptionsWidget(
                      userId: _userIdFromContext(context),
                      questionId: id,
                      selected: state.dynamicSelected,
                      onSelect: cubit.selectDynamic,
                      onClear: cubit.clearDynamic,
                    ),
                    UnknownQuestion(:final questionType) =>
                      _UnsupportedQuestionView(questionType: questionType),
                  },
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// userId доступен только после `start()`. Берём его через progress нельзя —
  /// поэтому Cubit хранит `_userId` приватно. Здесь же DynamicOptionsWidget
  /// получает userId напрямую из Cubit через приватный API. Чтобы не
  /// усложнять — используем `state.progress`-инвариант: к моменту, когда
  /// показывается dynamic question, userId уже точно есть в Cubit; вытащим
  /// его через прямой публичный метод.
  int _userIdFromContext(BuildContext context) {
    // Cubit хранит userId внутри; чтобы не плодить публичных полей,
    // используем callback-стиль: dynamic widget вызывает usecase сам через DI.
    // Здесь возвращаем актуальный userId через cubit.
    return context.read<QuestionnaireCubit>().userId;
  }
}

class _QuestionBottomBar extends StatelessWidget {
  const _QuestionBottomBar({
    required this.canSubmit,
    required this.onSubmit,
    required this.canSkip,
    required this.onSkip,
  });

  final bool canSubmit;
  final VoidCallback onSubmit;
  final bool canSkip;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuestionFooter(
            canSubmit: canSubmit,
            onSubmit: onSubmit,
            canSkip: canSkip,
            onSkip: onSkip,
          ),
        ],
      ),
    );
  }
}

/// Fallback для неизвестного `question_type` — лучше явный «не поддерживается»,
/// чем тихий рендер пустого single-choice с возможностью отправить мусор.
class _UnsupportedQuestionView extends StatelessWidget {
  const _UnsupportedQuestionView({required this.questionType});

  final String questionType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UiCard(
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 22,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Text(
                AppStrings.questionnaire.unsupportedTitle,
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.questionnaire.unsupportedBody,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm - 2),
          Text(
            'question_type: $questionType',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
