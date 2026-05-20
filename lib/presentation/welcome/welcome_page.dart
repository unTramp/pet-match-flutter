import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/cache/session_cache.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import 'widgets/decorations.dart';
import 'widgets/language_toggle.dart';

/// Hero-экран приветствия.
///
/// Композиция (по ревью):
/// * Кот занимает правую нижнюю четверть экрана (full-bleed).
/// * За ним мягкий лавандовый blob — единственный декор.
/// * Над котом — gradient overlay (cream solid слева → прозрачный),
///   который скрывает зеленоватый ореол PNG-обтравки и обеспечивает
///   читаемость текста.
/// * Текст и CTA — слева, акцентное слово в H1 выделено фиолетовым.
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late Future<bool> _hasActiveSession;
  bool _imagePrecached = false;

  @override
  void initState() {
    super.initState();
    _hasActiveSession = sl<SessionCache>().hasActiveSession();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagePrecached) {
      _imagePrecached = true;
      // Декодим PNG заранее, чтобы первый кадр не подтормаживал.
      precacheImage(const AssetImage('assets/images/cat.png'), context);
    }
  }

  Future<void> _onRestart() async {
    await sl<SessionCache>().clearSession();
    if (!mounted) return;
    setState(() {
      _hasActiveSession = Future.value(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.cream,
      ),
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                right: -80,
                bottom: 180,
                child: LavenderBlob(size: 320),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                width: screenWidth * 0.7,
                child: Image.asset(
                  'assets/images/cat.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                  semanticLabel: 'Иллюстрация кота',
                ),
              ),
              const Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [0.0, 0.4, 0.85],
                        colors: [
                          AppColors.cream,
                          Color(0xCCF7F1E7),
                          Color(0x00F7F1E7),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerRight,
                      child: LanguageToggle(),
                    ),
                    const Spacer(flex: 2),
                    _HeroHeadline(theme: theme),
                    const SizedBox(height: 14),
                    Text(
                      'Несколько коротких вопросов о вашем образе жизни '
                      '— и мы покажем, какие породы подойдут именно вам.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const Spacer(flex: 3),
                    FutureBuilder<bool>(
                      future: _hasActiveSession,
                      builder: (context, snapshot) {
                        // Оптимистичный рендер: всегда показываем кнопку.
                        // Когда hasActiveSession резолвится — мягко
                        // обновляем label.
                        final hasSession = snapshot.data ?? false;
                        return _BottomActions(
                          hasSession: hasSession,
                          onPressed: () => context.go(
                            hasSession ? '/questionnaire' : '/intro',
                          ),
                          onRestart: hasSession ? _onRestart : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroHeadline extends StatelessWidget {
  const _HeroHeadline({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final baseStyle = theme.textTheme.headlineLarge?.copyWith(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      height: 1.1,
      color: AppColors.textPrimary,
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(text: 'Найдём питомца, '),
            TextSpan(
              text: 'который вам подойдёт.',
              style: baseStyle?.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.hasSession,
    required this.onPressed,
    required this.onRestart,
  });

  final bool hasSession;
  final VoidCallback onPressed;
  final VoidCallback? onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: GradientButton(
            key: ValueKey<bool>(hasSession),
            label: hasSession ? 'Продолжить' : 'Подобрать питомца',
            onPressed: onPressed,
          ),
        ),
        if (onRestart != null) ...[
          const SizedBox(height: 6),
          TextButton(
            onPressed: onRestart,
            child: const Text('Начать заново'),
          ),
        ],
        const SizedBox(height: 10),
        Center(
          child: Text(
            '≈ 2 минуты · 5–7 вопросов',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary.withValues(alpha: 0.85),
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}
