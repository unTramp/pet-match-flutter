import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Визуальный переключатель RU/EN. Не меняет локаль приложения — серверный
/// контент по-прежнему идёт через `LocaleInterceptor` с локалью по умолчанию.
/// Сделано для соответствия дизайну. Интеграция с реальным переключением
/// языка вне scope тестового задания.
enum AppLang { ru, en }

class LanguageToggle extends StatefulWidget {
  const LanguageToggle({super.key, this.initial = AppLang.ru});

  final AppLang initial;

  @override
  State<LanguageToggle> createState() => AppLanguageToggleState();
}

class AppLanguageToggleState extends State<LanguageToggle> {
  late AppLang _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.lavenderTint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangChip(
            label: 'RU',
            selected: _selected == AppLang.ru,
            onTap: () => setState(() => _selected = AppLang.ru),
          ),
          _LangChip(
            label: 'EN',
            selected: _selected == AppLang.en,
            onTap: () => setState(() => _selected = AppLang.en),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
