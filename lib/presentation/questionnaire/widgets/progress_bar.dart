import 'package:flutter/material.dart';

import '../../../core/design/content/app_strings.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/progress.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.progress, this.stepTypeLabel});

  final Progress progress;
  final String? stepTypeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${AppStrings.questionnaire.progressLabel} ${progress.answered + 1} из ${progress.total}',
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            Text(
              '${progress.percentInt}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (stepTypeLabel != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            stepTypeLabel!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: LinearProgressIndicator(
            value: progress.percent,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
