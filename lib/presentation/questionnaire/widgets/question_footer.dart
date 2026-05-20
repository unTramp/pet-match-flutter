import 'package:flutter/material.dart';

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
          label: 'Продолжить',
          onPressed: canSubmit ? onSubmit : null,
        ),
        if (canSkip) ...[
          const SizedBox(height: 8),
          TextButton(onPressed: onSkip, child: const Text('Пропустить')),
        ],
      ],
    );
  }
}
