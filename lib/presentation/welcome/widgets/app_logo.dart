import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';

/// Бренд-знак. По умолчанию — иконка + текст «PET MATCH AI».
/// При `showText: false` рендерится только square-badge (используется на
/// Result-экране как кликабельный лого в AppBar.leading).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.showText = true, this.size = 40});

  final bool showText;
  final double size;

  @override
  Widget build(BuildContext context) {
    final badge = _Badge(size: size);
    if (!showText) return badge;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        const SizedBox(width: 10),
        const Text(
          'PET MATCH AI',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/icons/cathead.svg',
        width: size * 0.65,
        height: size * 0.5,
        colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      ),
    );
  }
}
