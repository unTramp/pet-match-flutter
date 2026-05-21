import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Карточная обёртка для нейтральной секции на Result-экране
/// («Что влияет на совпадение?», «Что важно знать», «Требования породы»).
/// Поддерживает единый визуальный язык с `OptionTile` и `MainBreedCard`:
/// surface-фон, тонкая warm-border, скругление 20.
class ResultSectionCard extends StatelessWidget {
  const ResultSectionCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: -4,
          ),
        ],
      ),
      child: child,
    );
  }
}
