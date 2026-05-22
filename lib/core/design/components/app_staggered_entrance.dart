import 'package:flutter/material.dart';

/// Shared fade + slide entrance for staggered screen sections.
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
