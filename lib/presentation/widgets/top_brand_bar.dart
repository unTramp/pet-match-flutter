import 'package:flutter/material.dart';

import '../../core/design/content/app_strings.dart';
import '../../core/design/tokens/spacing.dart';
import '../welcome/widgets/app_logo.dart';
import '../welcome/widgets/locale_badge.dart';

class TopBrandBar extends StatelessWidget {
  const TopBrandBar({
    super.key,
    this.onLogoTap,
    this.showLocaleBadge = true,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.xxxxl,
      AppSpacing.xl,
      AppSpacing.xxxxl,
      AppSpacing.xl,
    ),
  });

  final VoidCallback? onLogoTap;
  final bool showLocaleBadge;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    const logo = AppLogo(key: ValueKey('top-brand-logo'));
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (onLogoTap == null)
            logo
          else
            Semantics(
              button: true,
              label: AppStrings.common.homeSemantic,
              child: GestureDetector(
                onTap: onLogoTap,
                behavior: HitTestBehavior.opaque,
                child: logo,
              ),
            ),
          if (showLocaleBadge) const LocaleBadge(),
        ],
      ),
    );
  }
}
