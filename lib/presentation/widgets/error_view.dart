import 'package:flutter/material.dart';

import '../../core/design/content/app_strings.dart';
import '../../core/failures.dart';
import '../../core/design/components/ui_state_view.dart';

/// Единая точка отображения ошибок в приложении. Принимает [AppFailure] и
/// показывает осмысленное сообщение по типу. `onRetry` — опционально:
/// если null, кнопка не показывается (например, на терминальных ошибках).
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.failure, this.onRetry});

  final AppFailure failure;
  final VoidCallback? onRetry;

  String get _message => switch (failure) {
    NetworkFailure() => AppStrings.common.errorNetwork,
    TimeoutFailure() => AppStrings.common.errorTimeout,
    ServerFailure() => AppStrings.common.errorServer,
    EmptyResponseFailure() => AppStrings.common.errorEmpty,
  };

  IconData get _icon => switch (failure) {
    NetworkFailure() => Icons.wifi_off_rounded,
    TimeoutFailure() => Icons.hourglass_empty_rounded,
    ServerFailure() => Icons.cloud_off_rounded,
    EmptyResponseFailure() => Icons.inbox_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return UiStateView.message(
      icon: _icon,
      message: _message,
      primaryLabel: onRetry != null ? AppStrings.common.retry : null,
      primaryAction: onRetry,
    );
  }
}
