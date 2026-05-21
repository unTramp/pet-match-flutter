import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/components/ui_card.dart';
import '../../core/design/content/app_strings.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/session.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/top_brand_bar.dart';
import 'cubit/questionnaire_cubit.dart';
import 'cubit/questionnaire_state.dart';
import 'widgets/dynamic_options_widget.dart';
import 'widgets/multiple_choice_widget.dart';
import 'widgets/progress_bar.dart';
import 'widgets/question_footer.dart';
import 'widgets/single_choice_widget.dart';

class QuestionnairePage extends StatelessWidget {
  const QuestionnairePage({super.key, this.initialSession});

  final Session? initialSession;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuestionnaireCubit>(
      create: (_) {
        final cubit = sl<QuestionnaireCubit>();
        final session = initialSession;
        if (session != null) {
          unawaited(
            Future<void>.microtask(() => cubit.startWithSession(session)),
          );
        } else {
          unawaited(Future<void>.microtask(cubit.start));
        }
        return cubit;
      },
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
        if (state is QuestionnaireResultReady) {
          context.go('/result', extra: state.compatibility);
        }
      },
      builder: (context, state) {
        final questionState = state is QuestionnaireQuestion ? state : null;
        final cubit = context.read<QuestionnaireCubit>();
        return PopScope(
          canPop: false,
          child: Scaffold(
            bottomNavigationBar:
                questionState == null
                    ? null
                    : _QuestionBottomBar(
                      canSubmit: questionState.canSubmit,
                      isSubmitting: questionState.isSubmitting,
                      onSubmit: cubit.submit,
                      canSkip: questionState.question.isOptional,
                      onSkip: cubit.skipCurrent,
                    ),
            body: SafeArea(
              child: Column(
                children: [
                  TopBrandBar(onLogoTap: () => context.go('/welcome')),
                  if (questionState?.isSubmitting == true)
                    const _SubmittingTopProgress(),
                  Expanded(
                    child: switch (state) {
                      QuestionnaireInitial() || QuestionnaireLoading() =>
                        LoadingView(message: AppStrings.questionnaire.loading),
                      QuestionnaireQuestion() => _QuestionBody(
                        state: state,
                        isSubmitting: state.isSubmitting,
                      ),
                      QuestionnaireError(:final failure) => ErrorView(
                        failure: failure,
                        onRetry:
                            () => context.read<QuestionnaireCubit>().retry(),
                      ),
                      QuestionnaireResultReady() => const LoadingView(),
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SubmittingTopProgress extends StatelessWidget {
  const _SubmittingTopProgress();

  @override
  Widget build(BuildContext context) {
    return const LinearProgressIndicator(minHeight: 2);
  }
}

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({required this.state, required this.isSubmitting});

  final QuestionnaireQuestion state;
  final bool isSubmitting;

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
          const SizedBox(height: AppSpacing.md),
          Divider(color: AppColors.border.withValues(alpha: 0.9), height: 1),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(question.title, style: theme.textTheme.headlineMedium),
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
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    opacity: isSubmitting ? 0.75 : 1,
                    child: IgnorePointer(
                      ignoring: isSubmitting,
                      child: switch (question) {
                        SingleChoiceQuestion(:final options) =>
                          SingleChoiceWidget(
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
                        DynamicOptionsQuestion(:final id) =>
                          DynamicOptionsWidget(
                            userId: _userIdFromContext(context),
                            questionId: id,
                            selected: state.dynamicSelected,
                            onSelect: cubit.selectDynamic,
                            enabled: !isSubmitting,
                          ),
                        UnknownQuestion(:final questionType) =>
                          _UnsupportedQuestionView(questionType: questionType),
                      },
                    ),
                  ),
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
    required this.isSubmitting,
    required this.onSubmit,
    required this.canSkip,
    required this.onSkip,
  });

  final bool canSubmit;
  final bool isSubmitting;
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
            isSubmitting: isSubmitting,
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
              const SizedBox(width: AppSpacing.smd),
              Text(
                AppStrings.questionnaire.unsupportedTitle,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.questionnaire.unsupportedBody,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'question_type: $questionType',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
