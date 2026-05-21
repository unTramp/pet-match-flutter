import 'package:flutter/animation.dart';

/// Motion tokens for subtle UI interactions.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration debounce = Duration(milliseconds: 400);

  static const Curve standardCurve = Curves.easeInOut;
}
