import 'package:flutter/material.dart';

import '../../../core/design/tokens/motion.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/locale/app_locale_controller.dart';
import '../../../core/theme/app_colors.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppLocaleController.instance,
      builder: (context, selected, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LangText(
              label: 'RU',
              active: selected == AppLanguage.ru,
              onTap:
                  () =>
                      AppLocaleController.instance.setLanguage(AppLanguage.ru),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text('/', style: Theme.of(context).textTheme.bodyMedium),
            ),
            _LangText(
              label: 'EN',
              active: selected == AppLanguage.en,
              onTap:
                  () =>
                      AppLocaleController.instance.setLanguage(AppLanguage.en),
            ),
          ],
        );
      },
    );
  }
}

class _LangText extends StatelessWidget {
  const _LangText({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.s,
        ),
        child: AnimatedDefaultTextStyle(
          duration: AppMotion.normal,
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color:
                active
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.55),
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.4,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
