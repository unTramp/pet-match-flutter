import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/components/animated_score_label.dart';
import '../../core/design/components/app_staggered_entrance.dart';
import '../../core/design/components/ui_button.dart';
import '../../core/design/components/ui_card.dart';
import '../../core/design/content/app_strings.dart';
import '../../core/design/tokens/alpha.dart';
import '../../core/design/tokens/motion.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/shadows.dart';
import '../../core/design/tokens/sizes.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/design/tokens/strokes.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/compatibility.dart';
import '../widgets/top_brand_bar.dart';
import 'widgets/reasons_section.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key, required this.compatibility});

  final Compatibility compatibility;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  static const int _collapsedLimit = 3;

  bool _showAllInfluences = false;
  bool _showAllInsights = false;
  bool _showAllRequirements = false;
  late final AnimationController _introController;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: AppMotion.heroIntro,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _introController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  void _openBreed(BuildContext context, int? breedId, {double? score}) {
    if (breedId == null) return;
    context.push(AppRoutes.breed(breedId), extra: score);
  }

  void _openPrimaryAction(BuildContext context) {
    final compat = widget.compatibility;
    final id = _bottomCtaBreedId(compat);
    if (id == null) return;
    _openBreed(context, id, score: _scoreForId(compat, id));
  }

  double? _scoreForId(Compatibility compat, int id) {
    if (compat.breedId == id) return compat.score;
    for (final s in compat.suggestions) {
      if (s.breedId == id) return s.score;
    }
    return null;
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

  int? _bottomCtaBreedId(Compatibility compatibility) {
    final primary = _primaryCompatibility(compatibility);
    if (primary?.breedId case final breedId?) return breedId;
    final suggestions = _visibleSuggestions(compatibility);
    if (suggestions.isEmpty) return null;
    return suggestions.first.breedId;
  }

  Compatibility _compatibilityFromSuggestion(CompatibilitySuggestion s) =>
      Compatibility(
        status: CompatibilityStatus.ready,
        breedId: s.breedId,
        breedName: s.breedName,
        imageUrl: s.imageUrl,
        score: s.score,
        risk: s.risk,
        summary: s.summary,
      );

  List<ReasonItem> _visibleItems(List<ReasonItem> source, bool showAll) {
    if (showAll || source.length <= _collapsedLimit) return source;
    return source.take(_collapsedLimit).toList(growable: false);
  }

  Widget _sectionWithExpand({
    required String title,
    required List<ReasonItem> items,
    required bool showAll,
    required VoidCallback onToggle,
    required IconData icon,
  }) {
    final visible = _visibleItems(items, showAll);
    final canExpand = items.length > _collapsedLimit;
    return _SoftSectionCard(
      icon: icon,
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

  /// Insights — единственная секция без icon-rows: все её пункты имели одну
  /// и ту же декоративную иконку (lightbulb), визуально перегружали блок и
  /// смещались относительно multiline-текста. Рендерим как буллит-лист.
  Widget _buildInsightsSection({
    required List<String> insights,
    required bool showAll,
    required VoidCallback onToggle,
  }) {
    final canExpand = insights.length > _collapsedLimit;
    final visible =
        showAll || !canExpand
            ? insights
            : insights.take(_collapsedLimit).toList(growable: false);

    return _SoftSectionCard(
      icon: Icons.pets_rounded,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.result.insights,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...List.generate(visible.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i == visible.length - 1 ? 0 : AppSpacing.md,
                  ),
                  child: _BulletRow(text: visible[i]),
                );
              }),
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
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compatibility = widget.compatibility;
    final primaryCompatibility = _primaryCompatibility(compatibility);
    final suggestions = _visibleSuggestions(compatibility);
    final bottomCtaBreedId = _bottomCtaBreedId(compatibility);
    final refusal = compatibility.refusal;

    final influences = <ReasonItem>[
      ...compatibility.hardReasons.map(
        (r) => ReasonItem(
          text: r.message,
          icon: Icons.close_rounded,
          color: AppColors.error,
        ),
      ),
      ...compatibility.risks.map(
        (r) => ReasonItem(
          text: r.message,
          icon: Icons.warning_amber_rounded,
          color: AppColors.warning,
        ),
      ),
    ];

    final insights = compatibility.insights;

    final requirementItems =
        compatibility.requirementHighlights
            .map(
              (text) => ReasonItem(
                text: text,
                icon: Icons.check_rounded,
                color: AppColors.textSecondary,
              ),
            )
            .toList();

    final hasVisibleContent =
        primaryCompatibility != null ||
        influences.isNotEmpty ||
        refusal != null ||
        insights.isNotEmpty ||
        requirementItems.isNotEmpty ||
        suggestions.isNotEmpty;

    if (!hasVisibleContent) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: UiButton(
            label: AppStrings.common.restart,
            onPressed: () => context.go(AppRoutes.welcome),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppStaggeredEntrance(
              controller: _introController,
              interval: const Interval(0.0, 0.4),
              child: const _EmptyResultView(),
            ),
          ),
        ),
      );
    }

    final primary = primaryCompatibility;

    return Scaffold(
      backgroundColor: AppColors.cream,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.md,
        ),
        child: UiButton(
          label:
              primary != null
                  ? AppStrings.result.ctaViewBreed
                  : AppStrings.result.ctaViewAlternatives,
          onPressed:
              bottomCtaBreedId != null
                  ? () => _openPrimaryAction(context)
                  : null,
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopBrandBar(onLogoTap: () => context.go(AppRoutes.welcome)),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  if (primary != null)
                    AppStaggeredEntrance(
                      controller: _introController,
                      interval: const Interval(0.0, 0.45),
                      child: _LifestyleHero(
                        compatibility: primary,
                      ),
                    ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // if (primary != null) ...[
                //   AppStaggeredEntrance(
                //     controller: _introController,
                //     interval: const Interval(0.2, 0.6),
                //     child: const _WhyMatchSection(),
                //   ),
                //   const SizedBox(height: AppSpacing.xxl),
                //   AppStaggeredEntrance(
                //     controller: _introController,
                //     interval: const Interval(0.28, 0.68),
                //     child: const _ImportantNotesSection(),
                //   ),
                //   const SizedBox(height: AppSpacing.xxl),
                // ],
                if (primary?.summary != null) ...[
                  AppStaggeredEntrance(
                    controller: _introController,
                    interval: const Interval(0.18, 0.58),
                    child: _SummarySection(summary: primary!.summary!),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
                if (influences.isNotEmpty) ...[
                  AppStaggeredEntrance(
                    controller: _introController,
                    interval: const Interval(0.25, 0.65),
                    child: _sectionWithExpand(
                      title: AppStrings.result.influences,
                      items: influences,
                      showAll: _showAllInfluences,
                      icon: Icons.auto_awesome_rounded,
                      onToggle:
                          () => setState(
                            () => _showAllInfluences = !_showAllInfluences,
                          ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
                if (refusal != null &&
                    ((refusal.title?.isNotEmpty ?? false) ||
                        (refusal.message?.isNotEmpty ?? false))) ...[
                  AppStaggeredEntrance(
                    controller: _introController,
                    interval: const Interval(0.32, 0.72),
                    child: _RefusalSection(refusal: refusal),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
                if (insights.isNotEmpty) ...[
                  AppStaggeredEntrance(
                    controller: _introController,
                    interval: const Interval(0.38, 0.78),
                    child: _buildInsightsSection(
                      insights: insights,
                      showAll: _showAllInsights,
                      onToggle:
                          () => setState(
                            () => _showAllInsights = !_showAllInsights,
                          ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
                if (requirementItems.isNotEmpty) ...[
                  AppStaggeredEntrance(
                    controller: _introController,
                    interval: const Interval(0.45, 0.85),
                    child: _sectionWithExpand(
                      title: AppStrings.result.requirements,
                      items: requirementItems,
                      showAll: _showAllRequirements,
                      icon: Icons.fact_check_rounded,
                      onToggle:
                          () => setState(
                            () => _showAllRequirements = !_showAllRequirements,
                          ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
                if (suggestions.isNotEmpty)
                  AppStaggeredEntrance(
                    controller: _introController,
                    interval: const Interval(0.55, 1.0),
                    child: _SuggestionsSection(
                      suggestions: suggestions,
                      onTap:
                          (s) => _openBreed(context, s.breedId, score: s.score),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LifestyleHero extends StatelessWidget {
  const _LifestyleHero({required this.compatibility});

  final Compatibility compatibility;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmall = screenWidth < 380;
        final breedName =
            compatibility.breedName ?? AppStrings.common.unknownBreed;
        final titleLength = breedName.length;

        // Адаптивный шрифт: длинные имена («Среднеазиатская овчарка») должны
        // влезать в левую колонку, не теряя визуальный вес.
        final titleFontSize =
            titleLength > 42
                ? 26.0
                : titleLength > 30
                ? 30.0
                : titleLength > 20
                ? 34.0
                : isSmall
                ? 36.0
                : 40.0;

final heroHeight = titleLength > 42 ? 510.0 : 485.0;
final imageHeight = isSmall ? 260.0 : 292.0;
final percentFontSize = isSmall ? 38.0 : 44.0;

        final scorePct =
            compatibility.score == null
                ? null
                : (compatibility.score! * 100).round();

        return SizedBox(
          height: heroHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
Positioned(
  right: -84,
  top: 16,
  child: Container(
    width: 320,
    height: 320,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.18),
          AppColors.lavenderTint.withValues(alpha: 0.58),
          AppColors.lavenderTint.withValues(alpha: 0.12),
        ],
      ),
    ),
  ),
),
Positioned(
  right: -22,
  top: 42,
  child: Hero(
    tag: 'breed_image_${compatibility.breedId}',
    child: Image.asset(
      'assets/images/dog_bg.png',
      height: imageHeight,
      fit: BoxFit.contain,
    ),
  ),
),
              Positioned(
                left: AppSpacing.xl,
                top: 0,
                right: screenWidth * 0.35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      breedName,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: titleFontSize,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    if (scorePct != null) ...[
                      const SizedBox(height: 22),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '$scorePct%',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: percentFontSize,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x1F000000),
                                  blurRadius: 18,
                                  offset: Offset(0, 8),
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite_border_rounded,
                              size: 21,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                                        const SizedBox(height: 14),
                    const _AiRecommendationBadge(),
                  ],
                ),
              ),
              Positioned(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: 0,
                child: const _ResultTraitGrid(),
              ),
            ],
          ),
        );
      },
    );
  }
}



class _AiRecommendationBadge extends StatelessWidget {
  const _AiRecommendationBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: AppStroke.hairline,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 14,
            color: AppColors.primary,
          ),
          SizedBox(width: 6),
          Text(
            'Рекомендовано AI',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultTraitGrid extends StatelessWidget {
  const _ResultTraitGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - AppSpacing.sm) / 2;

        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: const [
            _TraitGridItem(
              icon: Icons.flash_on_rounded,
              label: 'Активность',
              value: 'Высокая',
            ),
            _TraitGridItem(
              icon: Icons.content_cut_rounded,
              label: 'Уход',
              value: 'Средний',
            ),
            _TraitGridItem(
              icon: Icons.home_rounded,
              label: 'Жильё',
              value: 'Квартира',
            ),
            _TraitGridItem(
              icon: Icons.psychology_rounded,
              label: 'Опыт',
              value: 'Желателен',
            ),
          ].map((item) => SizedBox(width: itemWidth, child: item)).toList(),
        );
      },
    );
  }
}

class _TraitGridItem extends StatelessWidget {
  const _TraitGridItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.surface.withValues(alpha: AppAlpha.borderMuted),
          width: AppStroke.hairline,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: AppAlpha.tint),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WhyMatchSection extends StatelessWidget {
  const _WhyMatchSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SoftSectionCard(
      icon: Icons.auto_awesome_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Почему это совпадение?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.md,
            children: [
              _CheckReason(text: 'Ритм жизни совпадает'),
              _CheckReason(text: 'Условия жилья подходят'),
              _CheckReason(text: 'Активность учтена'),
              _CheckReason(text: 'Готовность к уходу учтена'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckReason extends StatelessWidget {
  const _CheckReason({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      //width: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: AppAlpha.tint),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportantNotesSection extends StatelessWidget {
  const _ImportantNotesSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SoftSectionCard(
      icon: Icons.pets_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Что важно знать',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Row(
            children: [
              Expanded(
                child: _MiniNote(
                  icon: Icons.directions_walk_rounded,
                  text: 'Нужны регулярные прогулки',
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniNote(
                  icon: Icons.psychology_rounded,
                  text: 'Требует умственной нагрузки',
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniNote(
                  icon: Icons.favorite_border_rounded,
                  text: 'Может быть чувствительной',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniNote extends StatelessWidget {
  const _MiniNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.lavenderTint.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SoftSectionCard(
      icon: Icons.auto_awesome_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.result.influences,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(summary, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _RefusalSection extends StatelessWidget {
  const _RefusalSection({required this.refusal});

  final CompatibilityRefusal refusal;

  @override
  Widget build(BuildContext context) {
    final title = refusal.title;
    final message = refusal.message;
    return _SoftSectionCard(
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title.isNotEmpty)
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          if (message != null && message.isNotEmpty) ...[
            if (title != null && title.isNotEmpty)
              const SizedBox(height: AppSpacing.sm),
            Text(message, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ],
      ),
    );
  }
}

class _SuggestionsSection extends StatelessWidget {
  const _SuggestionsSection({required this.suggestions, required this.onTap});

  final List<CompatibilitySuggestion> suggestions;
  final ValueChanged<CompatibilitySuggestion> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder:
                (context, index) => _LifestyleSuggestionCard(
                  suggestion: suggestions[index],
                  onTap: () => onTap(suggestions[index]),
                ),
          ),
        ),
      ],
    );
  }
}

class _LifestyleSuggestionCard extends StatelessWidget {
  const _LifestyleSuggestionCard({
    required this.suggestion,
    required this.onTap,
  });

  final CompatibilitySuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = suggestion.imageUrl;
    return Semantics(
      button: true,
      label:
          suggestion.score == null
              ? suggestion.breedName
              : '${suggestion.breedName}, ${(suggestion.score! * 100).round()}%',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.card,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'breed_image_${suggestion.breedId}',
                child:
                    imageUrl == null
                        ? Container(
                          color: AppColors.lavenderTint,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.pets_rounded,
                            size: AppIconSize.xxxl,
                            color: AppColors.primary,
                          ),
                        )
                        : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (_, __) => Container(color: AppColors.border),
                          errorWidget:
                              (_, __, ___) => Container(
                                color: AppColors.lavenderTint,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.pets_rounded,
                                  size: AppIconSize.xxxl,
                                  color: AppColors.primary,
                                ),
                              ),
                        ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.overlayDark.withValues(alpha: 0.06),
                      AppColors.overlayDark.withValues(alpha: 0.04),
                      AppColors.overlayDark.withValues(alpha: 0.72),
                    ],
                    stops: const [0.0, 0.42, 1.0],
                  ),
                ),
              ),
              if (suggestion.score != null)
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: _ScoreChip(score: suggestion.score!),
                ),
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      suggestion.breedName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w800,
                        height: 1.08,
                      ),
                    ),
                    if (suggestion.summary != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        suggestion.summary!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.surface.withValues(alpha: 0.84),
                        ),
                      ),
                    ],
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

/// Frosted-glass score chip over a suggestion image.
///
/// BackdropFilter даёт «iOS glass» эффект — сквозь chip просвечивает image
/// + светлый tint поверх делает текст читаемым на любой palette. Тонкий
/// surface-border + лёгкая тень визуально приподнимают chip над фото.
class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(
              color: AppColors.surface.withValues(alpha: AppAlpha.borderMuted),
              width: AppStroke.hairline,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: AppIconSize.md,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${(score * 100).round()}%',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Text(
            '•',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SoftSectionCard extends StatelessWidget {
  const _SoftSectionCard({
    required this.child,
    required this.icon,
    this.iconColor = AppColors.primary,
  });

  final Widget child;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppControlSize.selector,
            height: AppControlSize.selector,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: AppAlpha.tint),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: AppIconSize.sm, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _EmptyResultView extends StatelessWidget {
  const _EmptyResultView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UiCard(
      child: Semantics(
        container: true,
        child: Column(
          children: [
            const Icon(
              Icons.pets_outlined,
              size: AppIconSize.emptyState,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.result.emptyTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.result.emptyBody,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
