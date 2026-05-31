/// Семантические токены прозрачности. Сюда выносятся все `withValues(alpha:)`,
/// чтобы оттенки одного и того же primary-цвета не расходились по экранам.
///
/// Семантика именования:
/// * `tint*` — прозрачность для tinted-фонов (значимый цвет × alpha → фон);
/// * `border*` — для линий, рамок, теней с цветом;
/// * `muted*` — для inactive-текста и тонких overlay;
/// * `shadow*` — для drop-shadow карточек;
/// * `overlay*` — для затемнений / gradient mid stops.
class AppAlpha {
  AppAlpha._();

  // Tints (color × alpha → background).
  static const double tintFaint = 0.04;
  static const double tintSubtle = 0.08;
  static const double tintSoft = 0.10;
  static const double tint = 0.12;

  // Borders / outlines / soft tinted shadows.
  static const double borderSubtle = 0.18;
  static const double borderMuted = 0.24;

  // Muted/disabled foreground.
  static const double mutedHeavy = 0.45;
  static const double muted = 0.55;
  static const double textOverSurface = 0.85;
  static const double divider = 0.9;

  // Overlay / gradient stops.
  static const double overlayMid = 0.80;

  // Drop shadows on neutral surfaces.
  static const double shadowFaint = 0.03;
  static const double shadowSoft = 0.04;
  static const double shadowMedium = 0.07;
  static const double shadowStrong = 0.08;
  static const double shadowEmphasis = 0.12;

  // Splash/hover/highlight.
  static const double splash = 0.06;
}
