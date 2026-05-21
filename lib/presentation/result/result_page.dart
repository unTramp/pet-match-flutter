import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/compatibility.dart';
import 'widgets/alert_block.dart';
import 'widgets/main_breed_card.dart';
import 'widgets/reasons_section.dart';
import 'widgets/refusal_block.dart';
import 'widgets/suggestion_card.dart';

/// Result-экран отображает **всё**, что отдаёт API:
///  * hero-карточка (фото + название + score с цветом по риску)
///  * summary
///  * блок «Что влияет на совпадение?» — hard_reasons + risks
///  * alert «Важно» — если есть refusal.title
///  * блок «Что важно учесть перед выбором» — refusal.external_message
///  * блок «Что важно знать» — insights
///  * блок «Требования породы» — requirement_highlights
///  * альтернативы
class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.compatibility});

  final Compatibility compatibility;

  void _openBreed(BuildContext context, int? breedId) {
    if (breedId == null) return;
    context.push('/breed/$breedId');
  }

  String _headerTitle() {
    if (compatibility.isRefused) return 'Не рекомендуем сейчас';
    if (compatibility.risk == CompatibilityRisk.medium) {
      return 'Подходит с оговорками';
    }
    return 'Лучшее совпадение';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = compatibility.suggestions;
    final hardReasons = compatibility.hardReasons;
    final risks = compatibility.risks;
    final insights = compatibility.insights;
    final requirements = compatibility.requirementHighlights;
    final refusal = compatibility.refusal;

    final influences = <ReasonItem>[
      ...hardReasons.map(
        (r) => ReasonItem(
          text: r.message,
          icon: Icons.close_rounded,
          color: AppColors.error,
        ),
      ),
      ...risks.map(
        (r) => ReasonItem(
          text: r.message,
          icon: Icons.warning_amber_rounded,
          color: AppColors.warning,
        ),
      ),
    ];

    final insightItems =
        insights
            .map(
              (text) => ReasonItem(
                text: text,
                icon: Icons.lightbulb_outline_rounded,
                color: AppColors.primary,
              ),
            )
            .toList();

    final requirementItems =
        requirements
            .map(
              (text) => ReasonItem(
                text: text,
                icon: Icons.check_rounded,
                color: AppColors.textSecondary,
              ),
            )
            .toList();

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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          physics: const BouncingScrollPhysics(),
          children: [
            Text(_headerTitle(), style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            MainBreedCard(
              compatibility: compatibility,
              onTap: () => _openBreed(context, compatibility.breedId),
            ),
            if (influences.isNotEmpty) ...[
              const SizedBox(height: 28),
              ReasonsSection(
                title: 'Что влияет на совпадение?',
                items: influences,
              ),
            ],
            if (refusal != null && (refusal.title?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 24),
              AlertBlock(
                title: 'Важно',
                message: refusal.title!,
                severity: AlertSeverity.danger,
              ),
            ],
            if (refusal != null && (refusal.message?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 16),
              RefusalBlock(
                title: 'Что важно учесть перед выбором',
                message: refusal.message!,
              ),
            ],
            if (insightItems.isNotEmpty) ...[
              const SizedBox(height: 28),
              ReasonsSection(title: 'Что важно знать', items: insightItems),
            ],
            if (requirementItems.isNotEmpty) ...[
              const SizedBox(height: 28),
              ReasonsSection(
                title: 'Требования породы',
                items: requirementItems,
              ),
            ],
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 32),
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
