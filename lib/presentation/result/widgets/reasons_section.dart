import 'package:flutter/material.dart';

import '../../../core/design/tokens/alpha.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/theme/app_colors.dart';

/// Одна строка в [ReasonsSection]: иконка + текст.
///
/// `plainIcon: true` отключает tinted-подложку под иконкой — нужно для
/// чек-листов (Requirements), где галочка читается лучше без рамки.
class ReasonItem {
  const ReasonItem({
    required this.text,
    required this.icon,
    required this.color,
    this.plainIcon = false,
  });

  final String text;
  final IconData icon;
  final Color color;
  final bool plainIcon;
}

/// Переиспользуемая секция «Что влияет на совпадение?», «Что важно знать»,
/// «Требования породы». Заголовок + список с цветной круглой иконкой слева.
class ReasonsSection extends StatelessWidget {
  const ReasonsSection({
    super.key,
    required this.title,
    required this.items,
    this.spacing = AppSpacing.xl,
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
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
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
        SizedBox(
          width: AppControlSize.selector,
          height: AppControlSize.selector,
          child: Container(
            margin: const EdgeInsets.only(top: AppSpacing.xxs),
            decoration:
                item.plainIcon
                    ? null
                    : BoxDecoration(
                      color: item.color.withValues(alpha: AppAlpha.tint),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
            alignment: Alignment.center,
            child: Icon(
              item.icon,
              size: item.plainIcon ? AppIconSize.lg : AppIconSize.sm,
              color: item.color,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          child: Text(
            item.text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
