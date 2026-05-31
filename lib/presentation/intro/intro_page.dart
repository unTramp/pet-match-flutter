import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/design/components/ui_button.dart';
import '../../core/design/content/app_strings.dart';
import '../../core/design/tokens/alpha.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/sizes.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/di/injection.dart';
import '../../core/failures.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/usecases/start_session.dart';
import '../widgets/top_brand_bar.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  bool _isStarting = false;

  List<_IntroBullet> get _bullets => [
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
        kRequestTimeout,
        onTimeout: () => throw const TimeoutFailure(),
      );
      if (!mounted) return;
      context.go(AppRoutes.questionnaire, extra: session);
    } on AppFailure catch (failure) {
      if (!mounted) return;
      _showStartError(failure);
    } catch (_) {
      if (!mounted) return;
      _showStartError(const ServerFailure.unexpected());
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  void _showStartError(AppFailure failure) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_failureMessage(failure))));
  }

  String _failureMessage(AppFailure failure) => switch (failure) {
    NetworkFailure() => AppStrings.common.errorNetwork,
    TimeoutFailure() => AppStrings.common.errorTimeout,
    ServerFailure() => AppStrings.common.errorServer,
    EmptyResponseFailure() => AppStrings.common.errorEmpty,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.xxxl,
          AppSpacing.md,
          AppSpacing.xxxl,
          AppSpacing.xl,
        ),
        child: UiButton(
          label: AppStrings.intro.ctaStart,
          onPressed: _onStartPressed,
          loading: _isStarting,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxxxl,
            AppSpacing.md,
            AppSpacing.xxxxl,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TopBrandBar(padding: EdgeInsets.zero),
              const SizedBox(height: AppSpacing.xxxxl),
              Text(
                AppStrings.intro.title,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppStrings.intro.subtitle,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxxxxl),
              ...List.generate(
                _bullets.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                  child: _bullets[i],
                ),
              ),
              const Spacer(),
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
          width: AppControlSize.tapTarget,
          height: AppControlSize.tapTarget,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: AppAlpha.tint),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.xxl),
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
