import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  static const _bullets = <_IntroBullet>[
    _IntroBullet(
      icon: Icons.question_answer_outlined,
      title: 'Ответьте на несколько вопросов',
      body: 'О вашем образе жизни, жилье и предпочтениях.',
    ),
    _IntroBullet(
      icon: Icons.psychology_outlined,
      title: 'Получите рекомендацию',
      body: 'Подберём породу, которая вам подходит больше всего.',
    ),
    _IntroBullet(
      icon: Icons.collections_outlined,
      title: 'Узнайте детали',
      body: 'Характер, уход, особенности и фотографии.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/welcome'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Как это работает', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Несколько вопросов — и подходящая порода у вас.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              ...List.generate(
                _bullets.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _bullets[i],
                ),
              ),
              const Spacer(),
              GradientButton(
                label: 'Начать анкету',
                onPressed: () => context.go('/questionnaire'),
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(body, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
