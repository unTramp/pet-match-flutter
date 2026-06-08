import 'package:flutter/material.dart';

import '../../../core/design/content/app_strings.dart';
import '../../../core/design/tokens/alpha.dart';
import '../../../core/design/tokens/motion.dart';
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
    final target = progress.percent.clamp(0.0, 1.0);
    final duration =
        MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : AppMotion.normal;
    return Semantics(
      container: true,
      label:
          '${AppStrings.questionnaire.progressLabel} ${progress.answered + 1} '
          '${AppStrings.questionnaire.progressOf} ${progress.total}.',
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: target),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, animatedFraction, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: SizedBox(
                        height: AppControlSize.progressBarHeight,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(color: AppColors.border),
                            FractionallySizedBox(
                              widthFactor: animatedFraction,
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
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  Text(
                    '${progress.answered + 1}/${progress.total}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
