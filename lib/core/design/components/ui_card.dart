import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../tokens/radius.dart';
import '../tokens/shadows.dart';
import '../tokens/spacing.dart';

class UiCard extends StatelessWidget {
  const UiCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.borderRadius = AppRadius.xxl,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.border),
          boxShadow: showShadow ? AppShadows.card : const [],
        ),
        child: child,
      ),
    );
  }
}
