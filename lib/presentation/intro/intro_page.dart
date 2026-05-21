import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/components/ui_button.dart';
import '../../core/design/content/app_strings.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/di/injection.dart';
import '../../core/failures.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/usecases/start_session.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  static const _prefetchTimeout = Duration(seconds: 15);
  bool _isStarting = false;

  static final _bullets = <_IntroBullet>[
    _IntroBullet(
      icon: Icons.question_answer_outlined,
      title: AppStrings.intro.bullet1Title,
      body: AppStrings.intro.bullet1Body,
    ),
    _IntroBullet(
      icon: Icons.psychology_outlined,
      title: AppStrings.intro.bullet2Title,
      body: AppStrings.intro.bullet2Body,
    ),
    _IntroBullet(
      icon: Icons.collections_outlined,
      title: AppStrings.intro.bullet3Title,
      body: AppStrings.intro.bullet3Body,
    ),
  ];

  Future<void> _onStartPressed() async {
    if (_isStarting) return;
    setState(() => _isStarting = true);
    try {
      final session = await sl<StartSession>()().timeout(
        _prefetchTimeout,
        onTimeout: () => throw const TimeoutFailure(),
      );
      if (!mounted) return;
      context.go('/questionnaire', extra: session);
    } catch (_) {
      if (!mounted) return;
      context.go('/questionnaire');
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            isIos ? CupertinoIcons.chevron_back : Icons.arrow_back_rounded,
          ),
          onPressed: () => context.go('/welcome'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.sm,
            AppSpacing.xxl,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.intro.title, style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.intro.subtitle,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              ...List.generate(
                _bullets.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: _bullets[i],
                ),
              ),
              const Spacer(),
              UiButton(
                label: AppStrings.intro.ctaStart,
                onPressed: _onStartPressed,
                loading: _isStarting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroBullet extends StatelessWidget {
  const _IntroBullet({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(body, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
