import 'package:flutter/material.dart';

import '../../../core/design/tokens/spacing.dart';
import '../../../domain/entities/option.dart';
import 'option_tile.dart';

class MultipleChoiceWidget extends StatelessWidget {
  const MultipleChoiceWidget({
    super.key,
    required this.options,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<QuestionOption> options;
  final Set<int> selectedIds;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(options.length, (i) {
        final opt = options[i];
        final selected = selectedIds.contains(opt.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: OptionTile(
            label: opt.label,
            selected: selected,
            onTap: () => onToggle(opt.id),
            trailing: selected ? const OptionCheck(selected: true) : null,
          ),
        );
      }),
    );
  }
}
