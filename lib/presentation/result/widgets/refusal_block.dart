import 'package:flutter/material.dart';

import '../../../core/design/tokens/alpha.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/theme/app_colors.dart';

/// Жёлтый блок «Что важно учесть перед выбором» — рендерит длинный
/// narrative-текст из `refusal.external_message`. Используется при отказе
/// или предупреждении.
class RefusalBlock extends StatelessWidget {
  const RefusalBlock({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.warningBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary.withValues(
                alpha: AppAlpha.textOverSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
