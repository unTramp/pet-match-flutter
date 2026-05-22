import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/components/ui_card.dart';
import '../../core/design/content/app_strings.dart';
import '../../core/design/tokens/alpha.dart';
import '../../core/design/tokens/motion.dart';
import '../../core/design/tokens/sizes.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/di/injection.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/session.dart';
import '../../domain/usecases/get_dynamic_options.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/top_brand_bar.dart';
import 'cubit/questionnaire_cubit.dart';
import 'cubit/questionnaire_state.dart';
import 'widgets/analyzing_view.dart';
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

  Future<void> _confirmExit(BuildContext context) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(AppStrings.questionnaire.exitConfirmTitle),
        content: Text(AppStrings.questionnaire.exitConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(AppStrings.questionnaire.exitConfirmStay),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(AppStrings.questionnaire.exitConfirmLeave),
          ),
        ],
      ),
    );
    if (shouldLeave == true && context.mounted) {
      context.go(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuestionnaireCubit, QuestionnaireState>(
      listener: (context, state) {
        if (state is QuestionnaireResultReady) {
          context.go(AppRoutes.result, extra: state.compatibility);
        }
      },
      builder: (context, state) {
        final questionState = state is QuestionnaireQuestion ? state : null;
        final cubit = context.read<QuestionnaireCubit>();
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;
            _confirmExit(context);
          },
          child: Scaffold(
            bottomNavigationBar: questionState == null
                ? null
                : SafeArea(
                    minimum: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.sm,
                      AppSpacing.xl,
                      AppSpacing.md,
                    ),
                    child: QuestionFooter(
                      canSubmit: questionState.canSubmit,
                      isSubmitting: questionState.isSubmitting,
                      onSubmit: cubit.submit,
                      canSkip: questionState.question.isOptional,
                      onSkip: cubit.skipCurrent,
                    ),
                  ),
            body: SafeArea(
              child: Column(
                children: [
                  TopBrandBar(onLogoTap: () => context.go(AppRoutes.welcome)),
                  if (questionState?.isSubmitting == true)
                    const LinearProgressIndicator(minHeight: 2),
                  Expanded(
                    child: switch (state) {
                      QuestionnaireInitial() || QuestionnaireLoading() =>
                        LoadingView(message: AppStrings.questionnaire.loading),
                      QuestionnaireQuestion() => _QuestionBody(
                        state: state,
                        isSubmitting: state.isSubmitting,
                      ),
                      QuestionnaireAnalyzing() => const AnalyzingView(),
                      QuestionnaireError(:final failure) => ErrorView(
                        failure: failure,
                        onRetry:
                            () => context.read<QuestionnaireCubit>().retry(),
                      ),
                      // Финальное состояние — listener уже инициировал
                      // переход на /result. Показываем тот же LoadingView,
                      // чтобы экран не «мигнул» пустотой во время transition.
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
          Divider(
            color: AppColors.border.withValues(alpha: AppAlpha.divider),
            height: 1,
          ),
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
                        color: AppColors.primary.withValues(
                          alpha: AppAlpha.textOverSurface,
                        ),
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
                          alpha: AppAlpha.divider,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  AnimatedOpacity(
                    duration: AppMotion.normal,
                    curve: Curves.easeOut,
                    opacity: isSubmitting ? 0.75 : 1,
                    child: IgnorePointer(
                      ignoring: isSubmitting,
                      child: switch (question) {
                        SingleChoiceQuestion(:final options) =>
                          SingleChoiceWidget(
                            options: options,
                            selectedId: state.selectedOptionIds.isEmpty
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
                            userId: state.userId,
                            questionId: id,
                            selected: state.dynamicSelected,
                            onSelect: cubit.selectDynamic,
                            enabled: !isSubmitting,
                            getDynamicOptions: sl<GetDynamicOptions>(),
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
                size: AppIconSize.xxl,
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
