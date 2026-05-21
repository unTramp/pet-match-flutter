import 'package:flutter/material.dart';

import '../../../core/design/tokens/alpha.dart';
import '../../../core/design/tokens/motion.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/shadows.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/theme/app_colors.dart';

/// Универсальная плашка ответа: белая карточка с радиусом 20, тонкой границей,
/// текстом слева и `trailing`-виджетом (radio / checkbox) справа.
///
/// Used by [SingleChoiceWidget] и [MultipleChoiceWidget]. Без иконок/эмодзи
/// слева — на скриншоте дизайна они есть, но пользователь явно попросил без них.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.xxl);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: AppColors.primary.withValues(alpha: AppAlpha.splash),
          highlightColor: AppColors.primary.withValues(alpha: AppAlpha.tintFaint),
          child: AnimatedContainer(
            duration: AppMotion.normal,
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: 18,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: radius,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.5 : 1,
              ),
              boxShadow:
                  selected
                      ? AppShadows.optionSelected(AppColors.primary)
                      : AppShadows.option,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                ExcludeSemantics(child: trailing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Кружочек radio в стиле дизайна: outlined серый круг → выбранный имеет
/// фиолетовую заливку внутри.
class OptionRadio extends StatelessWidget {
  const OptionRadio({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.normal,
      width: AppControlSize.selector,
      height: AppControlSize.selector,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color:
              selected
                  ? AppColors.primary
                  : AppColors.textSecondary.withValues(alpha: AppAlpha.mutedHeavy),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: AppMotion.normal,
        curve: Curves.easeOutBack,
        child: Container(
          width: AppControlSize.selectorDot,
          height: AppControlSize.selectorDot,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Чекбокс в стиле дизайна для multi-choice: тот же круг + галочка вместо
/// заливки. Цвета совпадают с [OptionRadio] для единообразия.
class OptionCheck extends StatelessWidget {
  const OptionCheck({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.normal,
      width: AppControlSize.selector,
      height: AppControlSize.selector,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color:
              selected
                  ? AppColors.primary
                  : AppColors.textSecondary.withValues(alpha: AppAlpha.mutedHeavy),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: AnimatedOpacity(
        opacity: selected ? 1 : 0,
        duration: AppMotion.normal,
        child: const Icon(
          Icons.check_rounded,
          size: AppIconSize.md,
          color: Colors.white,
        ),
      ),
    );
  }
}
