import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Одна строка в [ReasonsSection]: иконка + текст.
class ReasonItem {
  const ReasonItem({
    required this.text,
    required this.icon,
    required this.color,
  });

  final String text;
  final IconData icon;
  final Color color;
}

/// Переиспользуемая секция «Что влияет на совпадение?», «Что важно знать»,
/// «Требования породы». Заголовок + список с цветной круглой иконкой слева.
class ReasonsSection extends StatelessWidget {
  const ReasonsSection({
    super.key,
    required this.title,
    required this.items,
    this.spacing = 12,
  });

  final String title;
  final List<ReasonItem> items;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(items.length, (i) {
          final item = items[i];
          return Padding(
            padding: EdgeInsets.only(
              bottom: i == items.length - 1 ? 0 : spacing,
            ),
            child: _ReasonRow(item: item),
          );
        }),
      ],
    );
  }
}

class _ReasonRow extends StatelessWidget {
  const _ReasonRow({required this.item});

  final ReasonItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(item.icon, size: 14, color: item.color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              height: 1.45,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
