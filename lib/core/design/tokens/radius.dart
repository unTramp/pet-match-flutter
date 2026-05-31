/// Radius scale for cards, inputs and controls.
class AppRadius {
  AppRadius._();

  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 16;
  static const double xxl = 20;

  /// Полное скругление (pill-shape): для бейджей, чипов, meter-сегментов.
  /// Намеренно «магическое» 999 — большое значение, заведомо превышающее
  /// половину любого реального размера, поэтому Flutter рисует капсулу.
  static const double pill = 999;
}
