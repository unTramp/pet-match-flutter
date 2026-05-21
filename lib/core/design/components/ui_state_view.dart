import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../tokens/spacing.dart';
import 'ui_button.dart';

class UiStateView extends StatelessWidget {
  const UiStateView.loading({super.key, this.message})
    : icon = null,
      primaryLabel = null,
      primaryAction = null,
      secondaryLabel = null,
      secondaryAction = null,
      loading = true;

  const UiStateView.message({
    super.key,
    required this.icon,
    required this.message,
    this.primaryLabel,
    this.primaryAction,
    this.secondaryLabel,
    this.secondaryAction,
  }) : loading = false;

  final IconData? icon;
  final String? message;
  final String? primaryLabel;
  final VoidCallback? primaryAction;
  final String? secondaryLabel;
  final VoidCallback? secondaryAction;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const CircularProgressIndicator(strokeWidth: 3)
            else if (icon != null)
              Icon(icon, size: 56, color: AppColors.textSecondary),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                message!,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
            if (primaryAction != null && primaryLabel != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              UiButton(label: primaryLabel!, onPressed: primaryAction),
            ],
            if (secondaryAction != null && secondaryLabel != null) ...[
              const SizedBox(height: AppSpacing.md),
              UiButton(
                label: secondaryLabel!,
                onPressed: secondaryAction,
                variant: UiButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
