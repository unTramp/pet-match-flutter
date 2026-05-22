/// Размерная шкала иконок. Используется во всех `Icon(size: ...)` —
/// заменяет ad-hoc литералы (14/16/18/20/22/48/56/64).
class AppIconSize {
  AppIconSize._();

  /// 14 — мелкие иконки внутри 24-точечного badge (reason row).
  static const double sm = 14;

  /// 16 — компактные акценты (option check, button icon при tight CTA).
  static const double md = 16;

  /// 18 — стандартные иконки в кнопках (`UiButton.icon`).
  static const double lg = 18;

  /// 20 — заголовочные акценты (`AlertBlock`).
  static const double xl = 20;

  /// 22 — диагностические иконки (unsupported question type, info).
  static const double xxl = 22;

  /// 48 — placeholder в карточках породы.
  static const double xxxl = 48;

  /// 56 — иконка в `UiStateView.message` (empty / error).
  static const double emptyState = 56;

  /// 64 — большая hero-иконка (`AnalyzingView`, gallery error).
  static const double hero = 64;
}

/// Размеры интерактивных контролов и декоративных контейнеров.
class AppControlSize {
  AppControlSize._();

  /// 44 — Material tap-target минимум (intro bullet badge).
  static const double tapTarget = 44;

  /// 52 — высота основных CTA-кнопок (см. `app_theme.dart`).
  static const double buttonHeight = 52;

  /// 24 — outer radio/check круг в `OptionTile`.
  static const double selector = 24;

  /// 18 — компактный spinner внутри CTA.
  static const double spinner = 18;

  /// 12 — inner dot выбранного radio.
  static const double selectorDot = 12;

  /// 8 — высота progress-bar внутри questionnaire.
  static const double progressBarHeight = 8;

  /// 72 — thumbnail в `SuggestionCard`.
  static const double thumb = 72;

  /// 40 — бренд-badge внутри `AppLogo`.
  static const double brandBadge = 40;

  /// 120 — пульсирующая окружность на `AnalyzingView`.
  static const double heroBadge = 120;

  /// 340 — декоративная LavenderBlob на welcome.
  static const double decorBlob = 340;
}
