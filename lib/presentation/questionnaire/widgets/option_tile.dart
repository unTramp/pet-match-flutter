import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/tokens/alpha.dart';
import '../../../core/design/tokens/motion.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/shadows.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/strokes.dart';
import '../../../core/theme/app_colors.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.xl);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: radius,
          splashColor: AppColors.primary.withValues(alpha: AppAlpha.splash),
          highlightColor: AppColors.primary.withValues(
            alpha: AppAlpha.tintFaint,
          ),
          child: AnimatedContainer(
            duration: AppMotion.normal,
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color:
                  selected
                      ? AppColors.primary.withValues(alpha: AppAlpha.tintSubtle)
                      : AppColors.surface,
              borderRadius: radius,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
              ),
              boxShadow:
                  selected
                      ? AppShadows.optionSelected(AppColors.primary)
                      : AppShadows.option,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  ExcludeSemantics(child: trailing),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OptionCheck extends StatelessWidget {
  const OptionCheck({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.normal,
      width: AppControlSize.selector,
      height: AppControlSize.selector,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color:
              selected
                  ? AppColors.primary
                  : AppColors.textSecondary.withValues(
                    alpha: AppAlpha.mutedHeavy,
                  ),
          width: AppStroke.regular,
        ),
      ),
      alignment: Alignment.center,
      child: AnimatedOpacity(
        opacity: selected ? 1 : 0,
        duration: AppMotion.normal,
        child: const Icon(
          Icons.check_rounded,
          size: AppIconSize.sm,
          color: AppColors.surface,
        ),
      ),
    );
  }
}
