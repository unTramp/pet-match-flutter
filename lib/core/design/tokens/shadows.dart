import 'package:flutter/material.dart';

import 'alpha.dart';

/// Теневая шкала: единообразные drop-shadow для карточек и выбранных опций.
/// Получатели — `UiCard` (`card`) и `OptionTile` (`option` / `optionSelected`).
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, AppAlpha.shadowFaint),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> get option => const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, AppAlpha.shadowSoft),
      offset: Offset(0, 6),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];

  /// Выбранный option: тень окрашивается primary-цветом для подчёркивания
  /// выделения. Цвет приходит снаружи, чтобы держать карточку в нейтральном
  /// токен-слое.
  static List<BoxShadow> optionSelected(Color tint) => [
    BoxShadow(
      color: tint.withValues(alpha: AppAlpha.borderSubtle),
      offset: const Offset(0, 6),
      blurRadius: 18,
      spreadRadius: -2,
    ),
  ];
}
