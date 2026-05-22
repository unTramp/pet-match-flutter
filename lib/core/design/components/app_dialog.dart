import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../tokens/radius.dart';

/// Действие в [AppDialog]: подпись + колбэк + флаг «деструктивное».
///
/// Деструктивный action подсвечивается цветом ошибки — так пользователь
/// понимает, что выбор приведёт к потере прогресса/данных.
class AppDialogAction {
  const AppDialogAction({
    required this.label,
    required this.value,
    this.isDestructive = false,
  });

  final String label;
  final bool value;
  final bool isDestructive;
}

/// Стандартизированный диалог-подтверждение. Используется вместо инлайнового
/// `AlertDialog`, чтобы текст/типографика/радиусы соответствовали остальной
/// дизайн-системе и чтобы диалоги были консистентны между экранами.
///
/// Возвращает значение [AppDialogAction.value] нажатой кнопки, либо `null`
/// если пользователь закрыл диалог тапом вне его области.
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.body,
    required this.primaryAction,
    this.secondaryAction,
  });

  final String title;
  final String body;
  final AppDialogAction primaryAction;
  final AppDialogAction? secondaryAction;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String body,
    required AppDialogAction primaryAction,
    AppDialogAction? secondaryAction,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (_) => AppDialog(
            title: title,
            body: body,
            primaryAction: primaryAction,
            secondaryAction: secondaryAction,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      title: Text(title, style: theme.textTheme.titleLarge),
      content: Text(body, style: theme.textTheme.bodyMedium),
      actions: [
        if (secondaryAction != null)
          TextButton(
            onPressed:
                () => Navigator.of(context).pop(secondaryAction!.value),
            child: Text(secondaryAction!.label),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(primaryAction.value),
          style: TextButton.styleFrom(
            foregroundColor:
                primaryAction.isDestructive
                    ? AppColors.error
                    : AppColors.primary,
          ),
          child: Text(primaryAction.label),
        ),
      ],
    );
  }
}
