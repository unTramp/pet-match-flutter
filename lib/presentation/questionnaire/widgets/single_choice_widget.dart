import 'package:flutter/material.dart';

import '../../../core/design/tokens/spacing.dart';
import '../../../domain/entities/option.dart';
import 'option_tile.dart';

class SingleChoiceWidget extends StatelessWidget {
  const SingleChoiceWidget({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelect,
  });

  final List<QuestionOption> options;
  final int? selectedId;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(options.length, (i) {
        final opt = options[i];
        final selected = opt.id == selectedId;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: OptionTile(
            label: opt.label,
            selected: selected,
            onTap: () => onSelect(opt.id),
            trailing: selected ? const OptionCheck(selected: true) : null,
          ),
        );
      }),
    );
  }
}
