import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/compatibility.dart';

class MainBreedCard extends StatelessWidget {
  const MainBreedCard({super.key, required this.compatibility, this.onTap});

  final Compatibility compatibility;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = compatibility.score;
    final scoreLabel = score != null ? '${(score * 100).round()}%' : '—';
    final imageUrl = compatibility.imageUrl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
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
                                size: 48,
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          compatibility.breedName ?? 'Порода',
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          scoreLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (compatibility.summary != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      compatibility.summary!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  if (compatibility.insights.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...compatibility.insights.map(
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                i,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (onTap != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Подробнее о породе',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
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
