import 'package:flutter/animation.dart';

/// Motion tokens for subtle UI interactions.
class AppMotion {
  AppMotion._();

  // Базовые длительности контролов и transitions.
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);

  // Семантические длительности экранов и hero-анимаций.
  static const Duration routeIn = Duration(milliseconds: 240);
  static const Duration routeOut = Duration(milliseconds: 220);
  static const Duration heroIntro = Duration(milliseconds: 900);
  static const Duration pulse = Duration(milliseconds: 1400);

  /// Tween-длительность для «оживающего» score counter на breed-карточках.
  /// 800 мс — достаточно чтобы было видно тик, не слишком много чтобы
  /// раздражать при возврате на экран.
  static const Duration scoreTicker = Duration(milliseconds: 800);

  static const Curve standardCurve = Curves.easeInOut;
}
