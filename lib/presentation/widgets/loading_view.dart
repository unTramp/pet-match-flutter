import 'package:flutter/material.dart';

import '../../core/design/content/app_strings.dart';
import '../../core/design/components/ui_state_view.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return UiStateView.loading(message: message ?? AppStrings.common.loadingDefault);
  }
}
