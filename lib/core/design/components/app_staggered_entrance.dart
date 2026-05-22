import 'package:flutter/material.dart';

/// Staggered fade + slide entrance.
///
/// Принимает один [controller] и [interval] (0..1 over the controller's
/// timeline). Внутри строит CurvedAnimation + Tween&lt;Offset&gt; и оборачивает
/// [child] в `FadeTransition` + `SlideTransition`.
///
/// Удобен для последовательных «втеканий» секций экрана: каждой секции
/// даём свой `Interval(begin, end)`, и они появляются с задержкой относительно
/// друг друга, при этом анимация остаётся «одной общей волной» (один
/// controller, одна длительность).
///
/// `MediaQuery.disableAnimations` уважается — если у пользователя
/// включён reduce-motion, child рендерится сразу в финальном состоянии
/// (opacity 1, offset zero).
class AppStaggeredEntrance extends StatelessWidget {
  const AppStaggeredEntrance({
    super.key,
    required this.controller,
    required this.interval,
    required this.child,
    this.slideOffset = const Offset(0, 0.08),
  });

  final AnimationController controller;
  final Interval interval;
  final Widget child;

  /// Сдвиг в долях высоты child — 0.08 ≈ 8% высоты блока, незаметный пуш снизу.
  final Offset slideOffset;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final curved = CurvedAnimation(parent: controller, curve: interval);
    final slide = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(curved);

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
