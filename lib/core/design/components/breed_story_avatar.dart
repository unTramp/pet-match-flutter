import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../tokens/alpha.dart';
import '../tokens/radius.dart';
import '../tokens/sizes.dart';
import '../tokens/spacing.dart';

/// Story-style avatar для секции «Похожие варианты»: круглая фотография
/// породы, обведённая прогресс-кольцом match-score, с pill-бейджем в верхнем
/// правом углу. Под аватаром — имя породы.
///
/// При первом рендере кольцо плавно «нарастает» от 0 до целевого score через
/// `TweenAnimationBuilder` — придаёт ощущение «вычисления совпадения».
class BreedStoryAvatar extends StatelessWidget {
  const BreedStoryAvatar({
    super.key,
    required this.breedName,
    required this.score,
    this.imageUrl,
    this.onTap,
    this.diameter = 104,
    this.activeColor = AppColors.primary,
  });

  final String breedName;
  final double score;
  final String? imageUrl;
  final VoidCallback? onTap;
  final double diameter;
  final Color activeColor;

  /// Высота, которую занимает виджет: круг + gap + 2 строки текста.
  static const double estimatedHeight = 160;

  /// Толщина основного primary-кольца. Тонкая линия в стиле IG Highlights —
  /// акцент создаётся не толщиной, а цветом + лёгкой тенью под аватаром.
  static const double _ringStroke = 4;

  /// Зазор между primary-кольцом и фото — белый «inset», создаёт
  /// instagram-style отделение, чтобы фото не сливалось с цветом кольца.
  static const double _whiteInset = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedScore = score.clamp(0.0, 1.0);
    // Диаметр области под фото (внутрь белой прокладки).
    final imageDiameter = diameter - 2 * (_ringStroke + _whiteInset);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: SizedBox(
        width: diameter + AppSpacing.xs,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: diameter,
              height: diameter,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Soft drop shadow под кругом — даёт IG-Highlights-стайл
                  // elevation. Сам DecoratedBox без color, поэтому видна
                  // только тень снаружи окружности.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.avatarShadowBase.withValues(
                              alpha: AppAlpha.shadowMedium,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Декоративная статичная track-обводка (без active arc) —
                  // score доносится через pill-бейдж, дублирование убрано.
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _StoryArcPainter(
                        trackColor: activeColor.withValues(
                          alpha: AppAlpha.tint,
                        ),
                        strokeWidth: _ringStroke,
                      ),
                    ),
                  ),
                  // Белая прокладка + фото.
                  Center(
                    child: Container(
                      width: diameter - 2 * _ringStroke,
                      height: diameter - 2 * _ringStroke,
                      padding: const EdgeInsets.all(_whiteInset),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(child: _buildImage(imageDiameter)),
                    ),
                  ),
                  // Score pill — свешивается за пределы круга как
                  // notification-badge. Зазор в дуге (36°) уже
                  // подготовлен под него.
                  Positioned(
                    top: -6,
                    right: -8,
                    child: _ScorePill(
                      score: clampedScore,
                      color: activeColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              breedName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(double size) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: size,
        height: size,
        color: AppColors.lavenderTint,
        alignment: Alignment.center,
        child: Icon(
          Icons.pets_rounded,
          size: AppIconSize.xxxl,
          color: activeColor,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: AppColors.lavenderTint),
      errorWidget:
          (_, __, ___) => Container(
            color: AppColors.lavenderTint,
            alignment: Alignment.center,
            child: Icon(
              Icons.pets_rounded,
              size: AppIconSize.xxxl,
              color: activeColor,
            ),
          ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.score, required this.color});

  final double score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = (score * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '$pct%',
        style: const TextStyle(
          color: AppColors.surface,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Декоративная статичная обводка-кольцо вокруг фото в стиле
/// instagram-stories. Не отражает score — это просто рамка. Информация о
/// match-score доносится через pill-бейдж (pill сидит поверх ring'а и
/// перекрывает соответствующий сегмент).
class _StoryArcPainter extends CustomPainter {
  const _StoryArcPainter({
    required this.trackColor,
    required this.strokeWidth,
  });

  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    final radius = (size.shortestSide - strokeWidth) / 2;
    canvas.drawCircle(size.center(Offset.zero), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _StoryArcPainter oldDelegate) {
    return oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
