import 'package:flutter/material.dart';

import '../../core/design/tokens/motion.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/theme/app_colors.dart';

/// Pill-shaped CTA с фиолетовым градиентом, тенью и иконкой-стрелкой.
/// Применяется для главных действий (Welcome → Start, Intro → Начать анкету,
/// Questionnaire → Продолжить). `Material` + `InkWell` дают ripple поверх
/// градиентного `Container`'а — у стандартного `ElevatedButton` нет
/// нативной поддержки градиентов.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    this.height = 64,
  });

  final String label;

  /// `null` → disabled state: opacity 0.4, без тени, без ripple.
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final radius = BorderRadius.circular(height / 2);
    final content = Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: radius,
        splashColor: Colors.white.withValues(alpha: 0.18),
        highlightColor: Colors.white.withValues(alpha: 0.08),
        child: Container(
          height: height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: AppSpacing.sm + 2),
                Icon(icon, size: 22, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );

    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.45,
      duration: AppMotion.fast,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryGradientStart,
              AppColors.primaryGradientEnd,
            ],
          ),
          borderRadius: radius,
          boxShadow:
              enabled
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      offset: const Offset(0, 12),
                      blurRadius: 24,
                      spreadRadius: -4,
                    ),
                  ]
                  : const [],
        ),
        child: content,
      ),
    );
  }
}
