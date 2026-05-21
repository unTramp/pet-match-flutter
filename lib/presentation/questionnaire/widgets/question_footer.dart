import 'package:flutter/material.dart';

import '../../../core/design/content/app_strings.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../widgets/gradient_button.dart';

class QuestionFooter extends StatelessWidget {
  const QuestionFooter({
    super.key,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GradientButton(
          label: AppStrings.questionnaire.continueCta,
          onPressed: canSubmit ? onSubmit : null,
        ),
        if (canSkip) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onSkip,
            child: const Text('Пропустить'),
          ),
        ],
      ],
    );
  }
}
