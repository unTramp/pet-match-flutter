import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/design/content/app_strings.dart';
import '../../../core/design/tokens/alpha.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/score_format.dart';
import '../../../domain/entities/compatibility.dart';

class MainBreedCard extends StatelessWidget {
  const MainBreedCard({super.key, required this.compatibility, this.onTap});

  final Compatibility compatibility;
  final VoidCallback? onTap;

  /// Цвет score badge зависит от риска и фактической совместимости.
  Color _scoreColor() {
    if (compatibility.compatible == false ||
        compatibility.risk == CompatibilityRisk.high) {
      return AppColors.error;
    }
    if (compatibility.risk == CompatibilityRisk.medium) {
      return AppColors.warning;
    }
    return AppColors.accent;
  }

  String _statusText() {
    if (compatibility.compatible == false ||
        compatibility.risk == CompatibilityRisk.high) {
      return AppStrings.result.chipRefused;
    }
    if (compatibility.risk == CompatibilityRisk.medium) {
      return AppStrings.result.chipMedium;
    }
    return AppStrings.result.chipGood;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreLabel = formatScorePercent(compatibility.score);
    final imageUrl = compatibility.imageUrl;
    final accent = _scoreColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                children: [
                  Positioned.fill(
                    child:
                        imageUrl != null
                            ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder:
                                  (_, __) => Container(color: AppColors.border),
                              errorWidget:
                                  (_, __, ___) => Container(
                                    color: AppColors.border,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.pets_rounded,
                                      size: AppIconSize.xxxl,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                            )
                            : Container(
                              color: AppColors.border,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.pets_rounded,
                                size: 48,
                                color: AppColors.textSecondary,
                              ),
                            ),
                  ),
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.overlayDark,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColors.surface.withValues(alpha: AppAlpha.borderMuted),
                        ),
                      ),
                      child: Text(
                        _statusText(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          compatibility.breedName ?? AppStrings.common.unknownBreed,
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.s,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: AppAlpha.tintSoft),
                          borderRadius: BorderRadius.circular(AppRadius.xxl),
                        ),
                        child: Text(
                          scoreLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (compatibility.summary != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      compatibility.summary!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  if (onTap != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: onTap,
                        child: Text(AppStrings.result.ctaViewBreed),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
