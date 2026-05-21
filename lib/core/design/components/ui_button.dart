import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                const SizedBox(width: 8),
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
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: CupertinoColors.activeBlue,
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DefaultTextStyle(
              style: const TextStyle(
                color: CupertinoColors.activeBlue,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              child: IconTheme(
                data: const IconThemeData(
                  color: CupertinoColors.activeBlue,
                ),
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
