import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/content/app_strings.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/compatibility.dart';
import '../welcome/widgets/app_logo.dart';
import 'widgets/alert_block.dart';
import 'widgets/main_breed_card.dart';
import 'widgets/reasons_section.dart';
import 'widgets/refusal_block.dart';
import 'widgets/result_section_card.dart';
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
    if (compatibility.isRefused) return AppStrings.result.headerRefused;
    if (compatibility.risk == CompatibilityRisk.medium) {
      return AppStrings.result.headerMedium;
    }
    return AppStrings.result.headerBest;
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
        title: Text(AppStrings.result.appBarTitle),
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.md,
            top: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              onTap: () => context.go('/welcome'),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: const AppLogo(showText: false, size: 36),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            28,
          ),
          physics: const BouncingScrollPhysics(),
          children: [
            Text(_headerTitle(), style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            MainBreedCard(
              compatibility: compatibility,
              onTap: () => _openBreed(context, compatibility.breedId),
            ),
            if (influences.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxl),
              ResultSectionCard(
                child: ReasonsSection(
                  title: AppStrings.result.influences,
                  items: influences,
                ),
              ),
            ],
            if (refusal != null && (refusal.title?.isNotEmpty ?? false)) ...[
              const SizedBox(height: AppSpacing.xxl),
              AlertBlock(
                title: AppStrings.result.important,
                message: refusal.title!,
                severity: AlertSeverity.danger,
              ),
            ],
            if (refusal != null && (refusal.message?.isNotEmpty ?? false)) ...[
              const SizedBox(height: AppSpacing.lg),
              RefusalBlock(
                title: AppStrings.result.refusalTitle,
                message: refusal.message!,
              ),
            ],
            if (insightItems.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxl),
              ResultSectionCard(
                child: ReasonsSection(
                  title: AppStrings.result.insights,
                  items: insightItems,
                ),
              ),
            ],
            if (requirementItems.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxl),
              ResultSectionCard(
                child: ReasonsSection(
                  title: AppStrings.result.requirements,
                  items: requirementItems,
                ),
              ),
            ],
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                AppStrings.result.suggestionsTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppStrings.result.suggestionsSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...suggestions.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
