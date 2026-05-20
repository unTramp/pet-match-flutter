import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Минимальный текстовый переключатель «RU / EN».
///
/// Не меняет локаль приложения — это визуальный элемент для соответствия
/// дизайну референса. Интеграция с реальным переключением языка вне scope.
enum AppLang { ru, en }

class LanguageToggle extends StatefulWidget {
  const LanguageToggle({super.key, this.initial = AppLang.ru});

  final AppLang initial;

  @override
  State<LanguageToggle> createState() => _LanguageToggleState();
}

class _LanguageToggleState extends State<LanguageToggle> {
  late AppLang _selected = widget.initial;

  void _set(AppLang lang) {
    if (_selected == lang) return;
    setState(() => _selected = lang);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LangText(
          label: 'RU',
          active: _selected == AppLang.ru,
          onTap: () => _set(AppLang.ru),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '/',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
        _LangText(
          label: 'EN',
          active: _selected == AppLang.en,
          onTap: () => _set(AppLang.en),
        ),
      ],
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
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: TextStyle(
            color:
                active
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.55),
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
            letterSpacing: 0.4,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
