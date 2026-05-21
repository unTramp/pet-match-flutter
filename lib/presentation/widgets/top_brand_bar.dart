import 'package:flutter/material.dart';

import '../../core/design/tokens/spacing.dart';
import '../welcome/widgets/app_logo.dart';
import '../welcome/widgets/language_toggle.dart';

class TopBrandBar extends StatelessWidget {
  const TopBrandBar({
    super.key,
    this.onLogoTap,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.xxl,
      AppSpacing.md,
      AppSpacing.xxl,
      AppSpacing.md,
    ),
  });

  final VoidCallback? onLogoTap;
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
            GestureDetector(
              onTap: onLogoTap,
              behavior: HitTestBehavior.opaque,
              child: logo,
            ),
          const LanguageToggle(),
        ],
      ),
    );
  }
}
