import 'package:flutter/material.dart';

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

  static const _bg = Color(0xFFFFF6E0); // тёплый жёлтый, читается на cream
  static const _border = Color(0xFFF0E1B8);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
