import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../content/app_strings.dart';
import '../tokens/alpha.dart';
import '../tokens/motion.dart';
import '../tokens/radius.dart';
import '../tokens/sizes.dart';
import '../tokens/spacing.dart';
import '../tokens/strokes.dart';

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
    final rawOnPressed = loading ? null : onPressed;
    final effectiveOnPressed =
        rawOnPressed == null
            ? null
            : () {
              HapticFeedback.lightImpact();
              rawOnPressed();
            };
    final spinnerColor =
        variant == UiButtonVariant.primary ? Colors.white : AppColors.primary;
    final spinner = Semantics(
      label: AppStrings.common.loadingDefault,
      child: SizedBox(
        width: AppControlSize.spinner,
        height: AppControlSize.spinner,
        child: CircularProgressIndicator(
          strokeWidth: AppStroke.loader,
          valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
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
                    Icon(icon, size: AppIconSize.lg),
                    const SizedBox(width: AppSpacing.sm),
                    Text(label),
                  ],
                ));

    if (isIos) {
      final button = switch (variant) {
        UiButtonVariant.primary => SizedBox(
          width: double.infinity,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              color:
                  effectiveOnPressed == null && !loading
                      ? AppColors.border
                      : AppColors.primary,
              boxShadow:
                  effectiveOnPressed == null && !loading
                      ? const []
                      : [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: AppAlpha.borderMuted,
                          ),
                          offset: const Offset(0, 10),
                          blurRadius: 24,
                          spreadRadius: -6,
                        ),
                      ],
            ),
            child: CupertinoButton(
              color: Colors.transparent,
              disabledColor: Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              minSize: AppControlSize.buttonHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              onPressed: effectiveOnPressed,
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
                child: IconTheme(
                  data: const IconThemeData(color: Colors.white),
                  child: child,
                ),
              ),
            ),
          ),
        ),
        UiButtonVariant.secondary => CupertinoButton(
          onPressed: effectiveOnPressed,
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: AppControlSize.buttonHeight,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.primary,
                width: AppStroke.regular,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: DefaultTextStyle(
              style: const TextStyle(color: AppColors.primary),
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
      return button;
    }

    final button = switch (variant) {
      UiButtonVariant.primary => ElevatedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      UiButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      UiButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
    };
    return Semantics(
      button: true,
      enabled: effectiveOnPressed != null,
      label: loading ? AppStrings.common.loadingDefault : label,
      child: button,
    );
  }
}
