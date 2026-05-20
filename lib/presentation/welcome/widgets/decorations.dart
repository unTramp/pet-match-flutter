import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Лёгкое pale-фиолетовое сердечко-декорация.
class HeartDeco extends StatelessWidget {
  const HeartDeco({super.key, this.size = 56, this.opacity = 0.25});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.favorite_rounded,
      size: size,
      color: AppColors.primary.withValues(alpha: opacity),
    );
  }
}

/// Sparkle-звёздочка для пустых углов экрана.
class SparkleDeco extends StatelessWidget {
  const SparkleDeco({super.key, this.size = 24, this.opacity = 0.5});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome,
      size: size,
      color: AppColors.primary.withValues(alpha: opacity),
    );
  }
}

/// Большая мягкая лавандовая «капля» за иллюстрацией кота.
class LavenderBlob extends StatelessWidget {
  const LavenderBlob({super.key, this.size = 380});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.lavenderTint,
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}
