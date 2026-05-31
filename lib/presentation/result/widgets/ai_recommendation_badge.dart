import 'package:flutter/material.dart';

import '../../../core/design/tokens/motion.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/theme/app_colors.dart';

class AiRecommendationBadge extends StatefulWidget {
  const AiRecommendationBadge({super.key});

  @override
  State<AiRecommendationBadge> createState() => _AiRecommendationBadgeState();
}

class _AiRecommendationBadgeState extends State<AiRecommendationBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.pulse * 3,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        final glowOpacity = 0.06 + (t * 0.04);
        final shimmerCenter = -1.4 + (t * 2.8);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface.withValues(alpha: 0.94),
                AppColors.lavenderTint.withValues(alpha: 0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: glowOpacity),
                blurRadius: 18,
                spreadRadius: -8,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: AppColors.surface.withValues(alpha: 0.28),
                blurRadius: 0,
                spreadRadius: 0,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(shimmerCenter - 0.45, -0.2),
                          end: Alignment(shimmerCenter + 0.45, 0.2),
                          colors: [
                            Colors.transparent,
                            AppColors.surface.withValues(alpha: 0.0),
                            AppColors.surface.withValues(alpha: 0.38),
                            AppColors.surface.withValues(alpha: 0.0),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.28, 0.5, 0.72, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 7,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Рекомендовано AI',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
