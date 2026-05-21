import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/components/ui_button.dart';
import '../../core/design/content/app_strings.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/compatibility.dart';
import 'widgets/alert_block.dart';
import 'widgets/main_breed_card.dart';
import 'widgets/reasons_section.dart';
import 'widgets/refusal_block.dart';
import 'widgets/result_section_card.dart';
import 'widgets/suggestion_card.dart';
import '../widgets/top_brand_bar.dart';

/// Result-экран отображает **всё**, что отдаёт API:
///  * hero-карточка (фото + название + score с цветом по риску)
///  * summary
///  * блок «Что влияет на совпадение?» — hard_reasons + risks
///  * alert «Важно» — если есть refusal.title
///  * блок «Что важно учесть перед выбором» — refusal.external_message
///  * блок «Что важно знать» — insights
///  * блок «Требования породы» — requirement_highlights
///  * альтернативы
class ResultPage extends StatefulWidget {
  const ResultPage({super.key, required this.compatibility});

  final Compatibility compatibility;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  static const int _collapsedLimit = 3;

  bool _showAllInfluences = false;
  bool _showAllInsights = false;
  bool _showAllRequirements = false;

  void _openBreed(BuildContext context, int? breedId) {
    if (breedId == null) return;
    context.push('/breed/$breedId');
  }

  void _openPrimaryAction(BuildContext context) {
    _openBreed(context, _primaryCompatibility(widget.compatibility)?.breedId);
  }

  Compatibility? _primaryCompatibility(Compatibility compatibility) {
    if (compatibility.breedId != null) return compatibility;
    final suggestions = compatibility.suggestions;
    if (suggestions.isEmpty) return null;
    return _compatibilityFromSuggestion(suggestions.first);
  }

  List<CompatibilitySuggestion> _visibleSuggestions(
    Compatibility compatibility,
  ) {
    if (compatibility.breedId != null) return compatibility.suggestions;
    return compatibility.suggestions.skip(1).toList(growable: false);
  }

  Compatibility _compatibilityFromSuggestion(CompatibilitySuggestion s) =>
      Compatibility(
        status: CompatibilityStatus.ready,
        breedId: s.breedId,
        breedName: s.breedName,
        imageUrl: s.imageUrl,
        score: s.score,
        risk: _riskFromSuggestion(s.riskLevel),
        summary: s.summary,
      );

  CompatibilityRisk _riskFromSuggestion(String? raw) => switch (raw) {
    'low' => CompatibilityRisk.low,
    'medium' => CompatibilityRisk.medium,
    'high' => CompatibilityRisk.high,
    _ => CompatibilityRisk.unknown,
  };

  List<ReasonItem> _visibleItems(List<ReasonItem> source, bool showAll) {
    if (showAll || source.length <= _collapsedLimit) return source;
    return source.take(_collapsedLimit).toList(growable: false);
  }

  Widget _sectionWithExpand({
    required String title,
    required List<ReasonItem> items,
    required bool showAll,
    required VoidCallback onToggle,
  }) {
    final visible = _visibleItems(items, showAll);
    final canExpand = items.length > _collapsedLimit;
    return ResultSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReasonsSection(title: title, items: visible),
          if (canExpand) ...[
            const SizedBox(height: AppSpacing.md),
            UiButton(
              label:
                  showAll
                      ? AppStrings.result.showLess
                      : AppStrings.result.showMore,
              onPressed: onToggle,
              variant: UiButtonVariant.text,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compatibility = widget.compatibility;
    final primaryCompatibility = _primaryCompatibility(compatibility);
    final suggestions = _visibleSuggestions(compatibility);
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
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.md,
        ),
        child: UiButton(
          label:
              primaryCompatibility != null
                  ? AppStrings.result.ctaViewBreed
                  : AppStrings.result.ctaViewAlternatives,
          onPressed:
              primaryCompatibility != null
                  ? () => _openPrimaryAction(context)
                  : null,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TopBrandBar(onLogoTap: () => context.go('/welcome')),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.xxxl,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  if (primaryCompatibility != null)
                    MainBreedCard(
                      compatibility: primaryCompatibility,
                      onTap:
                          () =>
                              _openBreed(context, primaryCompatibility.breedId),
                    ),
                  if (influences.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    _sectionWithExpand(
                      title: AppStrings.result.influences,
                      items: influences,
                      showAll: _showAllInfluences,
                      onToggle:
                          () => setState(
                            () => _showAllInfluences = !_showAllInfluences,
                          ),
                    ),
                  ],
                  if (refusal != null &&
                      (refusal.title?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    AlertBlock(
                      title: AppStrings.result.important,
                      message: refusal.title!,
                      severity: AlertSeverity.danger,
                    ),
                  ],
                  if (refusal != null &&
                      (refusal.message?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: AppSpacing.lg),
                    RefusalBlock(
                      title: AppStrings.result.refusalTitle,
                      message: refusal.message!,
                    ),
                  ],
                  if (insightItems.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    _sectionWithExpand(
                      title: AppStrings.result.insights,
                      items: insightItems,
                      showAll: _showAllInsights,
                      onToggle:
                          () => setState(
                            () => _showAllInsights = !_showAllInsights,
                          ),
                    ),
                  ],
                  if (requirementItems.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    _sectionWithExpand(
                      title: AppStrings.result.requirements,
                      items: requirementItems,
                      showAll: _showAllRequirements,
                      onToggle:
                          () => setState(
                            () => _showAllRequirements = !_showAllRequirements,
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
          ],
        ),
      ),
    );
  }
}
