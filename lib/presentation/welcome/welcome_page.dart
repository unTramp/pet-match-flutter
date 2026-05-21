import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/cache/session_cache.dart';
import '../../core/design/components/ui_button.dart';
import '../../core/design/content/app_strings.dart';
import '../../core/design/tokens/motion.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/di/injection.dart';
import '../../core/failures.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/usecases/start_session.dart';
import 'widgets/decorations.dart';
import '../widgets/top_brand_bar.dart';

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

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  static const _prefetchTimeout = Duration(seconds: 15);
  late Future<bool> _hasActiveSession;
  late final AnimationController _introController;
  late final Animation<double> _headlineFade;
  late final Animation<Offset> _headlineSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _ctaFade;
  late final Animation<Offset> _ctaSlide;
  bool _imagePrecached = false;
  bool _isContinuing = false;

  @override
  void initState() {
    super.initState();
    _hasActiveSession = sl<SessionCache>().hasActiveSession();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headlineFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _headlineSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _subtitleFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.28, 0.84, curve: Curves.easeOutQuart),
      ),
    );
    _ctaFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _ctaSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // На iOS первый layout/paint может "съесть" начало анимации.
      // Стартуем после первого кадра с короткой паузой.
      await Future<void>.delayed(const Duration(milliseconds: 40));
      if (!mounted) return;
      unawaited(_introController.forward(from: 0));
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
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

  Future<void> _onContinueToQuestionnaire() async {
    if (_isContinuing) return;
    setState(() => _isContinuing = true);
    var navigated = false;
    try {
      final session = await sl<StartSession>()().timeout(
        _prefetchTimeout,
        onTimeout: () => throw const TimeoutFailure(),
      );
      if (!mounted) return;
      navigated = true;
      context.go('/questionnaire', extra: session);
    } catch (_) {
      if (!mounted) return;
      navigated = true;
      context.go('/questionnaire');
    } finally {
      if (mounted && !navigated) {
        setState(() => _isContinuing = false);
      }
    }
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
        body: Stack(
          children: [
            const Positioned(
              right: -80,
              bottom: 200,
              child: LavenderBlob(size: 340),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              width: screenWidth * 0.78,
              child: Image.asset(
                'assets/images/cat.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
                semanticLabel: AppStrings.welcome.catImageSemantic,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: const [0.0, 0.4, 0.85],
                      colors: [
                        AppColors.cream,
                        AppColors.cream.withValues(alpha: 0.8),
                        AppColors.cream.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.md,
                  AppSpacing.xxl,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TopBrandBar(padding: EdgeInsets.zero),
                    const Spacer(flex: 1),
                    _AnimatedTextEntrance(
                      fade: _headlineFade,
                      slide: _headlineSlide,
                      child: _HeroHeadline(theme: theme),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _AnimatedTextEntrance(
                      fade: _subtitleFade,
                      slide: _subtitleSlide,
                      child: Text(
                        AppStrings.welcome.subtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const Spacer(flex: 5),
                    _AnimatedTextEntrance(
                      fade: _ctaFade,
                      slide: _ctaSlide,
                      child: FutureBuilder<bool>(
                        future: _hasActiveSession,
                        builder: (context, snapshot) {
                          // Оптимистичный рендер: всегда показываем кнопку.
                          // Когда hasActiveSession резолвится — мягко
                          // обновляем label.
                          final hasSession = snapshot.data ?? false;
                          return _BottomActions(
                            hasSession: hasSession,
                            loading: _isContinuing,
                            onPressed:
                                hasSession
                                    ? _onContinueToQuestionnaire
                                    : () => context.go('/intro'),
                            onRestart: hasSession ? _onRestart : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedTextEntrance extends StatelessWidget {
  const _AnimatedTextEntrance({
    required this.fade,
    required this.slide,
    required this.child,
  });

  final Animation<double> fade;
  final Animation<Offset> slide;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

class _HeroHeadline extends StatelessWidget {
  const _HeroHeadline({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final baseStyle = theme.textTheme.headlineLarge?.copyWith(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      height: 1.1,
      letterSpacing: -0.45,
      color: AppColors.textPrimary,
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: AppStrings.welcome.heroLine1),
            TextSpan(
              text: AppStrings.welcome.heroLine2,
              style: baseStyle?.copyWith(color: AppColors.primary),
            ),
            TextSpan(text: AppStrings.welcome.heroLine3),
          ],
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.hasSession,
    required this.loading,
    required this.onPressed,
    required this.onRestart,
  });

  final bool hasSession;
  final bool loading;
  final VoidCallback onPressed;
  final VoidCallback? onRestart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSwitcher(
          duration: AppMotion.normal,
          child: UiButton(
            key: ValueKey<bool>(hasSession),
            label:
                hasSession
                    ? AppStrings.welcome.ctaContinue
                    : AppStrings.welcome.ctaStart,
            onPressed: onPressed,
            loading: loading,
          ),
        ),
        if (onRestart != null) ...[
          const SizedBox(height: AppSpacing.s),
          TextButton(
            onPressed: onRestart,
            child: Text(AppStrings.common.restart),
          ),
        ],
      ],
    );
  }
}
