import 'package:flutter/material.dart';

import '../../../core/design/tokens/sizes.dart';
import '../../../core/theme/app_colors.dart';

/// Большая мягкая лавандовая «капля» за иллюстрацией кота — единственный
/// декоративный элемент на Welcome. Hearts/Sparkles сознательно удалены
/// после ревью: они конкурировали с фотографией.
class LavenderBlob extends StatelessWidget {
  const LavenderBlob({super.key, this.size = AppControlSize.decorBlob});

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
