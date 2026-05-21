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
