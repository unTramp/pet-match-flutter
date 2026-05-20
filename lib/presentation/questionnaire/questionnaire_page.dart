import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
        return Scaffold(
          appBar: AppBar(
            title: const Text('Анкета'),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => context.go('/welcome'),
            ),
          ),
          body: SafeArea(
            child: switch (state) {
              QuestionnaireInitial() || QuestionnaireLoading() =>
                const LoadingView(message: 'Загружаем анкету…'),
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
}

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({required this.state});

  final QuestionnaireQuestion state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<QuestionnaireCubit>();
    final question = state.question;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProgressBar(progress: state.progress),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(question.title, style: theme.textTheme.headlineMedium),
                  if (question.helpText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      question.helpText!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
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
                  },
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          QuestionFooter(
            canSubmit: state.canSubmit,
            onSubmit: cubit.submit,
            canSkip: question.isOptional,
            onSkip: cubit.skipCurrent,
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
