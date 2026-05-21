import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

enum UiButtonVariant { primary, secondary, text }

class UiButton extends StatelessWidget {
  const UiButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = UiButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final UiButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    final child =
        icon == null
            ? Text(label)
            : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(label),
              ],
            );

    if (isIos) {
      return switch (variant) {
        UiButtonVariant.primary => SizedBox(
          width: double.infinity,
          child: CupertinoButton.filled(onPressed: onPressed, child: child),
        ),
        UiButtonVariant.secondary => CupertinoButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 52),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    color: AppColors.primary,
                  ),
                  child: IconTheme(
                    data: const IconThemeData(color: AppColors.primary),
                    child: child,
                  ),
                ),
          ),
        ),
        UiButtonVariant.text => CupertinoButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          child: Text(label),
        ),
      };
    }

    return switch (variant) {
      UiButtonVariant.primary => ElevatedButton(
        onPressed: onPressed,
        child: child,
      ),
      UiButtonVariant.secondary => OutlinedButton(
        onPressed: onPressed,
        child: child,
      ),
      UiButtonVariant.text => TextButton(onPressed: onPressed, child: child),
    };
  }
}
