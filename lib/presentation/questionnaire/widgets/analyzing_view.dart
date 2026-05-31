import 'package:flutter/material.dart';

import '../../../core/assets.dart';
import '../../../core/design/content/app_strings.dart';
import '../../../core/design/tokens/motion.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/theme/app_colors.dart';

class AnalyzingView extends StatefulWidget {
  const AnalyzingView({super.key});

  @override
  State<AnalyzingView> createState() => _AnalyzingViewState();
}

class _AnalyzingViewState extends State<AnalyzingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppMotion.pulse,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                final pulse = Curves.easeInOut.transform(_pulseController.value);
                final scale = 0.96 + (pulse * 0.08);
                final glowOpacity = 0.16 + (pulse * 0.14);

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: glowOpacity,
                          ),
                          blurRadius: 44,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      AppAssets.analyzingImage,
                      width: 165,
                      height: 165,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 44),
            Text(
              AppStrings.analyzing.title,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.analyzing.subtitle,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
