import 'package:flutter/material.dart';

import '../tokens/motion.dart';

/// Animated «N%» label.
///
/// Тикает от 0 до [score] (0..1) за [AppMotion.scoreTicker]. Эффект:
/// результат «оживает» при первом отображении карточки. Если у
/// пользователя включён reduce-motion — рендерит финальное значение
/// без анимации.
///
/// Для `score == null` рендерит [emptyLabel] (по умолчанию em-dash).
class AnimatedScoreLabel extends StatelessWidget {
  const AnimatedScoreLabel({
    super.key,
    required this.score,
    this.style,
    this.emptyLabel = '—',
  });

  final double? score;
  final TextStyle? style;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final value = score;
    if (value == null) return Text(emptyLabel, style: style);

    final duration =
        MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : AppMotion.scoreTicker;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        return Text('${(animated * 100).round()}%', style: style);
      },
    );
  }
}
