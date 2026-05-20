import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/compatibility.dart';
import 'widgets/main_breed_card.dart';
import 'widgets/suggestion_card.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.compatibility});

  final Compatibility compatibility;

  void _openBreed(BuildContext context, int? breedId) {
    if (breedId == null) return;
    context.push('/breed/$breedId');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = compatibility.suggestions;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Результат'),
        leading: IconButton(
          icon: const Icon(Icons.home_rounded),
          onPressed: () => context.go('/welcome'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          physics: const BouncingScrollPhysics(),
          children: [
            Text('Лучшее совпадение', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            MainBreedCard(
              compatibility: compatibility,
              onTap: () => _openBreed(context, compatibility.breedId),
            ),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 28),
              Text('Похожие варианты', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Альтернативные породы по вашему профилю.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              ...suggestions.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SuggestionCard(
                    suggestion: s,
                    onTap: () => _openBreed(context, s.breedId),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
