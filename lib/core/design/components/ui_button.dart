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
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final UiButtonVariant variant;
  final IconData? icon;

  /// Когда true — кнопка disabled и вместо label показывает компактный
  /// CircularProgressIndicator. Высота кнопки сохраняется, чтобы layout
  /// не «прыгал» при переключении.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    final effectiveOnPressed = loading ? null : onPressed;
    final spinner = SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2.2,
        valueColor: AlwaysStoppedAnimation<Color>(
          variant == UiButtonVariant.primary ? Colors.white : AppColors.primary,
        ),
      ),
    );
    final child =
        loading
            ? spinner
            : (icon == null
                ? Text(label)
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Text(label),
                  ],
                ));

    if (isIos) {
      return switch (variant) {
        UiButtonVariant.primary => SizedBox(
          width: double.infinity,
          child: CupertinoButton.filled(onPressed: effectiveOnPressed, child: child),
        ),
        UiButtonVariant.secondary => CupertinoButton(
          onPressed: effectiveOnPressed,
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
          onPressed: effectiveOnPressed,
          padding: EdgeInsets.zero,
          child: child,
        ),
      };
    }

    return switch (variant) {
      UiButtonVariant.primary => ElevatedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      UiButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      UiButtonVariant.text => TextButton(onPressed: effectiveOnPressed, child: child),
    };
  }
}
