import 'package:flutter/material.dart';

import '../../../core/design/components/breed_mini_gauge.dart';
import '../../../core/design/tokens/alpha.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/breed_attributes.dart';

class CharacteristicsSection extends StatelessWidget {
  const CharacteristicsSection({super.key, required this.attributes});

  final BreedAttributes attributes;

  static const _iconBase = 'assets/icons/prototype_traits';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _items(attributes);
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

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
        const SizedBox(height: AppSpacing.xl),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _ResultCharacteristicCard(item: item),
          ),
      ],
    );
  }

  static List<_ResultCharacteristicItem> _items(BreedAttributes attributes) {
    final items = <_ResultCharacteristicItem?>[
      _item(
        title: 'Потребность в нагрузке',
        description:
            'Сколько активности нужно собаке для хорошего самочувствия',
        assetPath: '$_iconBase/exercise_runner.png',
        level: attributes.exerciseNeeds,
      ),
      _item(
        title: 'Обучаемость',
        description: 'Насколько легко собака поддаётся обучению',
        assetPath: '$_iconBase/pedigree_medal.png',
        level: attributes.trainability,
      ),
      _item(
        title: 'Линька',
        description: 'Сколько шерсти будет дома в период линьки',
        assetPath: '$_iconBase/shedding_fur.png',
        level: attributes.sheddingLevel,
      ),
      _item(
        title: 'Потребность в уходе',
        description: 'Сколько времени и усилий нужно на уход и гигиену',
        assetPath: '$_iconBase/grooming_brush.png',
        level: attributes.groomingNeeds,
      ),
      _item(
        title: 'Отношение к детям',
        description: 'Насколько спокойно и дружелюбно собака ладит с детьми',
        assetPath: '$_iconBase/good_with_children.png',
        level: attributes.goodWithChildren,
      ),
      _item(
        title: 'Стоимость содержания',
        description: 'Финансовые затраты на содержание, питание и уход',
        assetPath: '$_iconBase/cost_bag.png',
        level: attributes.maintenanceCost,
      ),
      _item(
        title: 'Переносит одиночество',
        description:
            'Насколько спокойно собака остаётся одна без лишней тревоги',
        assetPath: '$_iconBase/home_alone.png',
        level: attributes.aloneTolerance,
      ),
    ];

    return items.whereType<_ResultCharacteristicItem>().toList(growable: false);
  }

  static _ResultCharacteristicItem? _item({
    required String title,
    required String description,
    required String assetPath,
    required int? level,
  }) {
    if (level == null) return null;
    return _ResultCharacteristicItem(
      title: title,
      description: description,
      assetPath: assetPath,
      level: level,
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
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            item.assetPath,
            width: _iconSize,
            height: _iconSize,
            fit: BoxFit.contain,
            errorBuilder:
                (context, error, stackTrace) => const Icon(
                  Icons.pets_rounded,
                  size: _iconSize,
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(width: AppSpacing.xxl),
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
          const SizedBox(width: AppSpacing.xxl),
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
