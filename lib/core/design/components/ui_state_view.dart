import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../content/app_strings.dart';
import '../tokens/sizes.dart';
import '../tokens/spacing.dart';
import '../tokens/strokes.dart';
import 'ui_button.dart';

class UiStateView extends StatelessWidget {
  const UiStateView.loading({super.key, this.message})
    : icon = null,
      primaryLabel = null,
      primaryAction = null,
      loading = true;

  const UiStateView.message({
    super.key,
    required this.icon,
    required this.message,
    this.primaryLabel,
    this.primaryAction,
  }) : loading = false;

  final IconData? icon;
  final String? message;
  final String? primaryLabel;
  final VoidCallback? primaryAction;
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
              Semantics(
                label: AppStrings.common.loadingDefault,
                child: const CircularProgressIndicator(
                  strokeWidth: AppStroke.strong,
                ),
              )
            else if (icon != null)
              Icon(
                icon,
                size: AppIconSize.emptyState,
                color: AppColors.textSecondary,
              ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              Text(
                message!,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
            if (primaryAction != null && primaryLabel != null) ...[
              const SizedBox(height: AppSpacing.xxxxl),
              UiButton(label: primaryLabel!, onPressed: primaryAction),
            ],
          ],
        ),
      ),
    );
  }
}
