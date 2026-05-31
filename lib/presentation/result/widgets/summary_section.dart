import 'package:flutter/material.dart';

import '../../../core/design/content/app_strings.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/shadows.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/theme/app_colors.dart';
import 'ai_recommendation_badge.dart';

class SummarySection extends StatelessWidget {
  const SummarySection({super.key, required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AiRecommendationBadge(),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.result.summaryTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(summary, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
