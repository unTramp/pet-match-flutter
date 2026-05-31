import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../tokens/motion.dart';
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
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: clampedScore),
              duration: AppMotion.storyRingIntro,
              curve: Curves.easeOutCubic,
              builder: (_, animatedProgress, __) {
                return SizedBox(
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
                                color: AppColors.shadowBase.withValues(
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
                      // Прогресс-кольцо с зазором под pill: track-дуга +
                      // active-дуга обе стартуют сразу за бейджем.
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _StoryArcPainter(
                            progress: animatedProgress,
                            activeColor: activeColor,
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
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
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
        horizontal: AppSpacing.sm,
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

/// Прогресс-кольцо с разрывом в верхнем-правом секторе под pill-бейджем.
/// Длина активной дуги пропорциональна `progress` (0..1) — позволяет
/// сравнивать варианты по высоте match-score «глазом» без чтения цифр.
class _StoryArcPainter extends CustomPainter {
  const _StoryArcPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color activeColor;
  final Color trackColor;
  final double strokeWidth;

  // Центр разрыва — на 1-2 часах (под pill-бейджем в Positioned top-right).
  static const double _gapCenter = -math.pi / 4;

  // Половина углового размера разрыва. ≈ 18° с каждой стороны = 36° total —
  // концы дуги подъезжают почти вплотную к pill-бейджу, оставляя только
  // тонкую «прорезь» вокруг него.
  static const double _gapHalf = math.pi / 10;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Старт — сразу за разрывом по часовой; sweep — почти полный круг
    // минус двойная половина разрыва.
    const startAngle = _gapCenter + _gapHalf;
    const sweepAngle = 2 * math.pi - 2 * _gapHalf;

    final trackPaint =
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    final activePaint =
        Paint()
          ..color = activeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _StoryArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
