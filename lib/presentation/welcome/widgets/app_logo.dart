import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets.dart';
import '../../../core/design/content/app_strings.dart';
import '../../../core/design/tokens/alpha.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/theme/app_colors.dart';

/// Бренд-знак: квадратный badge со старой иконкой + текст бренда.
/// Используется в `TopBrandBar` в верхней панели экранов.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  static const double _size = AppControlSize.brandBadge;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Badge(size: _size),
        const SizedBox(width: AppSpacing.smd),
        Text(
          AppStrings.common.appBrand,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
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
        color: AppColors.primary.withValues(alpha: AppAlpha.tint),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        AppAssets.brandIcon,
        width: size * 0.65,
        height: size * 0.5,
        colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      ),
    );
  }
}
