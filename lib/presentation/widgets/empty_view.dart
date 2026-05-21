import 'package:flutter/material.dart';

import '../../core/design/components/ui_state_view.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.message,
    this.onAction,
    this.actionLabel,
  });

  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return UiStateView.message(
      icon: Icons.inbox_outlined,
      message: message,
      primaryLabel: actionLabel,
      primaryAction: onAction,
    );
  }
}
