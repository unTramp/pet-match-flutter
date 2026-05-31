import 'package:flutter/material.dart';

import '../../../core/assets.dart';
import '../../../core/design/content/app_strings.dart';
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
        const SizedBox(width: AppSpacing.lg),
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
  static const double _iconInset = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Padding(
        padding: const EdgeInsets.all(_iconInset),
        child: Image.asset(
          AppAssets.topBrandIcon,
          width: size - (_iconInset * 2),
          height: size - (_iconInset * 2),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
