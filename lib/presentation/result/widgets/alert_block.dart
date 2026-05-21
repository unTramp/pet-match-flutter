import 'package:flutter/material.dart';

import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/theme/app_colors.dart';

enum AlertSeverity { info, warning, danger }

/// Короткий alert-блок: иконка + заголовок + текст.
/// Цветовая полоса слева подбирается по severity.
class AlertBlock extends StatelessWidget {
  const AlertBlock({
    super.key,
    required this.title,
    required this.message,
    this.severity = AlertSeverity.warning,
  });

  final String title;
  final String message;
  final AlertSeverity severity;

  Color get _accent => switch (severity) {
    AlertSeverity.info => AppColors.primary,
    AlertSeverity.warning => AppColors.warning,
    AlertSeverity.danger => AppColors.error,
  };

  IconData get _icon => switch (severity) {
    AlertSeverity.info => Icons.info_outline_rounded,
    AlertSeverity.warning => Icons.warning_amber_rounded,
    AlertSeverity.danger => Icons.error_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border(left: BorderSide(color: _accent, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _accent, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
