import 'package:flutter/animation.dart';

/// Motion tokens for subtle UI interactions.
class AppMotion {
  AppMotion._();

  // Базовые длительности контролов и transitions.
  /// Микро-пауза перед стартом тяжёлой анимации (нужна, чтобы первый layout
  /// успел отрисоваться и не «съел» начало).
  static const Duration instant = Duration(milliseconds: 40);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);

  /// Между обычным переходом и hero — для тактильных задержек перед
  /// навигацией, чтобы пользователь успел увидеть отклик на тап.
  static const Duration slow = Duration(milliseconds: 400);

  // Семантические длительности экранов и hero-анимаций.
  static const Duration routeIn = Duration(milliseconds: 240);
  static const Duration routeOut = Duration(milliseconds: 220);
  static const Duration heroIntro = Duration(milliseconds: 900);
  static const Duration pulse = Duration(milliseconds: 1400);

  static const Duration scoreTicker = Duration(milliseconds: 800);
  static const Duration gaugeIntro = Duration(milliseconds: 450);
  static const Duration storyRingIntro = Duration(milliseconds: 700);

  static const Curve standardCurve = Curves.easeInOut;
}
