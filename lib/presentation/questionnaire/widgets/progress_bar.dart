import 'package:flutter/material.dart';

import '../../../core/design/content/app_strings.dart';
import '../../../core/design/tokens/alpha.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/progress.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.progress});

  final Progress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label:
          '${AppStrings.questionnaire.progressLabel} ${progress.answered + 1} '
          '${AppStrings.questionnaire.progressOf} ${progress.total}, '
          '${progress.percentInt}%. ${AppStrings.questionnaire.timeEstimate}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${AppStrings.questionnaire.progressLabel} '
                '${progress.answered + 1} '
                '${AppStrings.questionnaire.progressOf} ${progress.total}',
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              Text(
                '${progress.percentInt}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary.withValues(
                    alpha: AppAlpha.textOverSurface,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox(
              height: AppControlSize.progressBarHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: AppColors.border),
                  FractionallySizedBox(
                    widthFactor: progress.percent.clamp(0.0, 1.0),
                    alignment: Alignment.centerLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(
                              alpha: AppAlpha.textOverSurface,
                            ),
                            AppColors.primary,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: AppIconSize.md,
                color: AppColors.primary.withValues(alpha: AppAlpha.muted),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                AppStrings.questionnaire.timeEstimate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
