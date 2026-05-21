import 'package:flutter/material.dart';

import '../../../core/design/components/ui_card.dart';

/// Карточная обёртка для нейтральной секции на Result-экране
/// («Что влияет на совпадение?», «Что важно знать», «Требования породы»).
/// Поддерживает единый визуальный язык с `OptionTile` и `MainBreedCard`:
/// surface-фон, тонкая warm-border, скругление 20.
class ResultSectionCard extends StatelessWidget {
  const ResultSectionCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return UiCard(child: child);
  }
}
