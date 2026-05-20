import 'package:flutter/material.dart';

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
    final radius = BorderRadius.circular(20);
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: AppColors.primary.withValues(alpha: 0.06),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: radius,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    selected
                        ? AppColors.primary.withValues(alpha: 0.18)
                        : Colors.black.withValues(alpha: 0.04),
                offset: const Offset(0, 6),
                blurRadius: selected ? 18 : 12,
                spreadRadius: -2,
              ),
            ],
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
              const SizedBox(width: 12),
              trailing,
            ],
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
      duration: const Duration(milliseconds: 180),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color:
              selected
                  ? AppColors.primary
                  : AppColors.textSecondary.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: Container(
          width: 12,
          height: 12,
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
      duration: const Duration(milliseconds: 180),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color:
              selected
                  ? AppColors.primary
                  : AppColors.textSecondary.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: AnimatedOpacity(
        opacity: selected ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
      ),
    );
  }
}
