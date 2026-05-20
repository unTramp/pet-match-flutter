import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/failures.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/usecases/poll_compatibility.dart';
import '../widgets/error_view.dart';

/// Промежуточный экран между концом анкеты и показом результата.
///
/// Запускает `PollCompatibility` в `initState` — операция одна, отдельный
/// Cubit избыточен. Состояние локально: либо ждём, либо ошибка.
class AnalyzingPage extends StatefulWidget {
  const AnalyzingPage({super.key, required this.userId});

  final int userId;

  @override
  State<AnalyzingPage> createState() => _AnalyzingPageState();
}

class _AnalyzingPageState extends State<AnalyzingPage>
    with SingleTickerProviderStateMixin {
  AppFailure? _failure;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _start();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() => _failure = null);
    try {
      final compatibility = await sl<PollCompatibility>()(
        userId: widget.userId,
      );
      if (!mounted) return;
      context.go('/result', extra: compatibility);
    } on AppFailure catch (f) {
      if (!mounted) return;
      setState(() => _failure = f);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child:
            _failure != null
                ? ErrorView(
                  failure: _failure!,
                  onRetry: _start,
                  onSecondary: () => context.go('/welcome'),
                  secondaryLabel: 'Начать заново',
                )
                : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScaleTransition(
                          scale: Tween<double>(begin: 0.92, end: 1.08).animate(
                            CurvedAnimation(
                              parent: _pulseController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.psychology_alt_rounded,
                              size: 64,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Анализируем ответы',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Подбираем подходящую породу под ваш профиль…',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
