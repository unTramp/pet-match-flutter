import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/cache/session_cache.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import 'widgets/app_logo.dart';
import 'widgets/decorations.dart';
import 'widgets/language_toggle.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late Future<bool> _hasActiveSession;

  @override
  void initState() {
    super.initState();
    _hasActiveSession = sl<SessionCache>().hasActiveSession();
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
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [AppLogo(), LanguageToggle()],
              ),
            ),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned(
                    right: -90,
                    bottom: 60,
                    child: LavenderBlob(size: 360),
                  ),
                  Positioned(
                    right: -40,
                    bottom: 0,
                    top: 60,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Image.asset(
                        'assets/images/cat.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  const Positioned(
                    right: 30,
                    top: 40,
                    child: SparkleDeco(size: 22),
                  ),
                  const Positioned(
                    right: 110,
                    top: 150,
                    child: HeartDeco(size: 54),
                  ),
                  const Positioned(
                    left: 40,
                    top: 280,
                    child: SparkleDeco(size: 16),
                  ),
                  const Positioned(
                    left: 30,
                    bottom: 100,
                    child: HeartDeco(size: 72, opacity: 0.22),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 280),
                          child: Text(
                            'Мы поможем подобрать питомца, который вам подойдет.',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 230),
                          child: Text(
                            'Ответьте на несколько вопросов, и мы покажем, '
                            'какие питомцы подходят вашему образу жизни и какие '
                            'могут создать сложности в будущем.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13.5,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: FutureBuilder<bool>(
                future: _hasActiveSession,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const SizedBox(
                      height: 64,
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  final hasSession = snapshot.data ?? false;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GradientButton(
                        label: hasSession ? 'Продолжить' : 'Начать',
                        onPressed:
                            () => context.go(
                              hasSession ? '/questionnaire' : '/intro',
                            ),
                      ),
                      if (hasSession) ...[
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _onRestart,
                          child: const Text('Начать заново'),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 14,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Ваши ответы конфиденциальны',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
