import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/motion.dart';
import '../../theme/app_colors.dart';

/// Компактный полукруглый спидометр для отображения уровня характеристики
/// породы по шкале 1..[max] (по умолчанию 1..5).
///
/// Размер ~58×42. Активная дуга — `activeColor`, фон — `trackColor`,
/// внизу по центру текст вида `3/5`. Анимация прогресса 450мс easeOutCubic.
class BreedMiniGauge extends StatelessWidget {
  const BreedMiniGauge({
    super.key,
    required this.value,
    this.max = 5,
    this.size = const Size(50, 44),
    this.activeColor = AppColors.primary,
    this.trackColor = AppColors.lavenderTint,
    this.strokeWidth = 6,
  });

  final int value;
  final int max;
  final Size size;
  final Color activeColor;
  final Color trackColor;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final progress = (value / max).clamp(0.0, 1.0);
    const labelHeight = 17.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: AppMotion.gaugeIntro,
      curve: Curves.easeOutCubic,
      builder: (_, animatedProgress, __) {
        return SizedBox(
          width: size.width,
          height: size.height,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: CustomPaint(
                  painter: _MiniGaugePainter(
                    progress: animatedProgress,
                    activeColor: activeColor,
                    trackColor: trackColor,
                    strokeWidth: strokeWidth,
                  ),
                  size: Size(size.width, size.height - labelHeight),
                ),
              ),
              SizedBox(
                height: labelHeight,
                child: Center(
                  child: Text(
                    '$value/$max',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: activeColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniGaugePainter extends CustomPainter {
  const _MiniGaugePainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color activeColor;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final diameter = math.min(
      size.width - strokeWidth,
      (size.height * 2) - strokeWidth,
    );
    final left = (size.width - diameter) / 2;
    final top = strokeWidth / 2;
    final rect = Rect.fromLTWH(left, top, diameter, diameter);

    final trackPaint =
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    final activePaint =
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.gaugeGradientStart,
              AppColors.gaugeGradientMid,
              AppColors.gaugeGradientEnd,
            ],
            stops: [0.0, 0.52, 1.0],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    const startAngle = math.pi;
    const sweepAngle = math.pi;

    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _MiniGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
