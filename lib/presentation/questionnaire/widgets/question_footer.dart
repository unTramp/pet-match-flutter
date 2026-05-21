import 'package:flutter/material.dart';

import '../../../core/design/components/ui_button.dart';
import '../../../core/design/content/app_strings.dart';
import '../../../core/design/tokens/spacing.dart';

class QuestionFooter extends StatelessWidget {
  const QuestionFooter({
    super.key,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiButton(
          label: AppStrings.questionnaire.continueCta,
          onPressed: (canSubmit && !isSubmitting) ? onSubmit : null,
          loading: isSubmitting,
        ),
        if (canSkip) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: isSubmitting ? null : onSkip,
            child: Text(AppStrings.questionnaire.skipCta),
          ),
        ],
      ],
    );
  }
}
