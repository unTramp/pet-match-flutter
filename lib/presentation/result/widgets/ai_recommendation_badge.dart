import 'package:flutter/material.dart';

import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/theme/app_colors.dart';

/// Статичный pill-бейдж «✨ Рекомендовано AI» над Summary-карточкой.
/// Статичный — без анимаций, чтобы не мешать `pumpAndSettle` в widget-тестах
/// и не нагружать UI-thread бесконечным AnimationController.
class AiRecommendationBadge extends StatelessWidget {
  const AiRecommendationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface.withValues(alpha: 0.9),
            AppColors.lavenderTint.withValues(alpha: 0.72),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 14,
            spreadRadius: -8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.primary),
          SizedBox(width: 6),
          Text(
            'Рекомендовано AI',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
