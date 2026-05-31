import 'package:flutter/material.dart';

import '../../../core/design/components/breed_mini_gauge.dart';
import '../../../core/design/tokens/alpha.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/theme/app_colors.dart';

class CharacteristicsSection extends StatelessWidget {
  const CharacteristicsSection({super.key});

  static const _iconBase = 'assets/icons/prototype_traits';

  static const _items = <_ResultCharacteristicItem>[
    _ResultCharacteristicItem(
      title: 'Потребность в нагрузке',
      description: 'Сколько активности нужно собаке для хорошего самочувствия',
      assetPath: '$_iconBase/exercise_runner.png',
      level: 3,
    ),
    _ResultCharacteristicItem(
      title: 'Обучаемость',
      description: 'Насколько легко собака поддаётся обучению',
      assetPath: '$_iconBase/pedigree_medal.png',
      level: 3,
    ),
    _ResultCharacteristicItem(
      title: 'Линька',
      description: 'Сколько шерсти будет дома в период линьки',
      assetPath: '$_iconBase/shedding_fur.png',
      level: 3,
    ),
    _ResultCharacteristicItem(
      title: 'Потребность в уходе',
      description: 'Сколько времени и усилий нужно на уход и гигиену',
      assetPath: '$_iconBase/grooming_brush.png',
      level: 3,
    ),
    _ResultCharacteristicItem(
      title: 'Отношение к детям',
      description: 'Насколько спокойно и дружелюбно собака ладит с детьми',
      assetPath: '$_iconBase/good_with_children.png',
      level: 3,
    ),
    _ResultCharacteristicItem(
      title: 'Здоровье породы',
      description: 'Общее состояние здоровья и склонность к частым проблемам',
      assetPath: '$_iconBase/health_heart.png',
      level: 5,
    ),
    _ResultCharacteristicItem(
      title: 'Стоимость содержания',
      description: 'Финансовые затраты на содержание, питание и уход',
      assetPath: '$_iconBase/cost_bag.png',
      level: 5,
    ),
    _ResultCharacteristicItem(
      title: 'Интеллект',
      description: 'Как быстро собака схватывает команды и новые паттерны',
      assetPath: '$_iconBase/intelligence_brain.png',
      level: 3,
    ),
    _ResultCharacteristicItem(
      title: 'Переносит одиночество',
      description: 'Насколько спокойно собака остаётся одна без лишней тревоги',
      assetPath: '$_iconBase/home_alone.png',
      level: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Характеристики',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final item in _items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _ResultCharacteristicCard(item: item),
          ),
      ],
    );
  }
}

class _ResultCharacteristicCard extends StatelessWidget {
  const _ResultCharacteristicCard({required this.item});

  final _ResultCharacteristicItem item;

  static const double _iconSize = 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, AppAlpha.shadowMedium),
            offset: Offset(0, 8),
            blurRadius: 18,
            spreadRadius: -8,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            item.assetPath,
            width: _iconSize,
            height: _iconSize,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.24,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          BreedMiniGauge(value: item.level.clamp(0, 5)),
        ],
      ),
    );
  }
}

class _ResultCharacteristicItem {
  const _ResultCharacteristicItem({
    required this.title,
    required this.description,
    required this.assetPath,
    required this.level,
  });

  final String title;
  final String description;
  final String assetPath;
  final int level;
}
