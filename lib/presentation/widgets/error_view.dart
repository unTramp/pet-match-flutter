import 'package:flutter/material.dart';

import '../../core/failures.dart';
import '../../core/theme/app_colors.dart';

/// Единая точка отображения ошибок в приложении. Принимает [AppFailure] и
/// показывает осмысленное сообщение по типу. `onRetry` — опционально:
/// если null, кнопка не показывается (например, на терминальных ошибках).
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.failure,
    this.onRetry,
    this.onSecondary,
    this.secondaryLabel,
  });

  final AppFailure failure;
  final VoidCallback? onRetry;
  final VoidCallback? onSecondary;
  final String? secondaryLabel;

  String get _message => switch (failure) {
    NetworkFailure() =>
      'Нет подключения к сети. Проверьте интернет и попробуйте снова.',
    TimeoutFailure() => 'Сервер долго не отвечает. Попробуйте позже.',
    ServerFailure() => 'Что-то пошло не так. Попробуйте снова.',
    EmptyResponseFailure() => 'Нет данных. Попробуйте снова.',
  };

  IconData get _icon => switch (failure) {
    NetworkFailure() => Icons.wifi_off_rounded,
    TimeoutFailure() => Icons.hourglass_empty_rounded,
    ServerFailure() => Icons.cloud_off_rounded,
    EmptyResponseFailure() => Icons.inbox_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              _message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Повторить'),
              ),
            ],
            if (onSecondary != null && secondaryLabel != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onSecondary,
                child: Text(secondaryLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
