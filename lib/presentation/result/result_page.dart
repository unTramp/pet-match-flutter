import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design/components/app_staggered_entrance.dart';
import '../../core/design/components/breed_story_avatar.dart';
import '../../core/design/components/ui_button.dart';
import '../../core/design/components/ui_card.dart';
import '../../core/design/content/app_strings.dart';
import '../../core/design/tokens/alpha.dart';
import '../../core/design/tokens/motion.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/shadows.dart';
import '../../core/design/tokens/sizes.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/compatibility.dart';
import '../widgets/top_brand_bar.dart';
import 'widgets/characteristics_section.dart';
import 'widgets/favorite_paw_button.dart';
import 'widgets/reasons_section.dart';
import 'widgets/summary_section.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key, required this.compatibility});

  final Compatibility compatibility;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
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

  void _openBreed(BuildContext context, String? breedId, {double? score}) {
    if (breedId == null) return;
    context.push(AppRoutes.breed(breedId), extra: score);
  }

  void _openPrimaryAction(BuildContext context) {
    final compat = widget.compatibility;
    final id = _bottomCtaBreedId(compat);
    if (id == null) return;
    _openBreed(context, id, score: _scoreForId(compat, id));
  }

  double? _scoreForId(Compatibility compat, String id) {
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

  String? _bottomCtaBreedId(Compatibility compatibility) {
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
        storyAvatarUrl: s.storyAvatarUrl,
        score: s.score,
        risk: s.risk,
        summary: s.summary,
        attributes: s.attributes,
      );

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

    final hasVisibleContent =
        primaryCompatibility != null ||
        influences.isNotEmpty ||
        refusal != null ||
        suggestions.isNotEmpty;

    if (!hasVisibleContent) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(
            AppSpacing.xxxl,
            AppSpacing.md,
            AppSpacing.xxxl,
            AppSpacing.xl,
          ),
          child: UiButton(
            label: AppStrings.common.restart,
            onPressed: () => context.go(AppRoutes.welcome),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
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
          AppSpacing.xxxl,
          AppSpacing.md,
          AppSpacing.xxxl,
          AppSpacing.xl,
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
                      child: _LifestyleHero(compatibility: primary),
                    ),
                  if (primary?.summary != null)
                    AppStaggeredEntrance(
                      controller: _introController,
                      interval: const Interval(0.08, 0.50),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xxxl,
                          0,
                          AppSpacing.xxxl,
                          0,
                        ),
                        child: _SummarySection(summary: primary!.summary!),
                      ),
                    ),
                  if (primary?.attributes case final attributes?
                      when !attributes.isEmpty)
                    AppStaggeredEntrance(
                      controller: _introController,
                      interval: const Interval(0.16, 0.56),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xxxl,
                          AppSpacing.xxxxl,
                          AppSpacing.xxxl,
                          0,
                        ),
                        child: _ResultCharacteristicsSection(
                          attributes: attributes,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xxxl,
                      AppSpacing.xxxxl,
                      AppSpacing.xxxl,
                      AppSpacing.xxxxxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (primary != null &&
                            compatibility.insights.isNotEmpty) ...[
                          AppStaggeredEntrance(
                            controller: _introController,
                            interval: const Interval(0.2, 0.6),
                            child: _WhyMatchSection(
                              insights: compatibility.insights,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxxxl),
                        ],
                        if (primary != null &&
                            (compatibility.requirementHighlights.isNotEmpty ||
                                influences.isNotEmpty)) ...[
                          AppStaggeredEntrance(
                            controller: _introController,
                            interval: const Interval(0.28, 0.68),
                            child: _ImportantNotesSection(
                              requirementHighlights:
                                  compatibility.requirementHighlights,
                              influences: influences,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxxxl),
                        ],
                        if (refusal != null &&
                            ((refusal.title?.isNotEmpty ?? false) ||
                                (refusal.message?.isNotEmpty ?? false))) ...[
                          AppStaggeredEntrance(
                            controller: _introController,
                            interval: const Interval(0.32, 0.72),
                            child: _RefusalSection(refusal: refusal),
                          ),
                          const SizedBox(height: AppSpacing.xxxxl),
                        ],
                        if (suggestions.isNotEmpty)
                          AppStaggeredEntrance(
                            controller: _introController,
                            interval: const Interval(0.55, 1.0),
                            child: _SuggestionsSection(
                              suggestions: suggestions,
                              onTap:
                                  (s) => _openBreed(
                                    context,
                                    s.breedId,
                                    score: s.score,
                                  ),
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
  static const double _smallScreenBreakpoint = 380;
  static const double _longTitleHeroHeight = 383;
  static const double _defaultHeroHeight = 358;
  static const double _smallImageHeight = 260;
  static const double _defaultImageHeight = 292;
  static const double _heroGlowOffsetRight = -134;
  static const double _heroGlowOffsetTop = 10;
  static const double _heroGlowSize = 440;
  static const double _heroImageOffsetRight = -32;
  static const double _heroImageOffsetTop = 60;
  static const double _titleColumnRightFactor = 0.35;
  static const double _titleLineHeight = 1.05;

  /// Подпись под процентом совпадения. Делит шкалу 0-100 на 4 диапазона,
  /// чтобы число обретало смысл («92%» само по себе не говорит, насколько
  /// это хорошо).
  static String _scoreLabel(int pct) {
    if (pct >= 85) return AppStrings.result.scoreLabelPerfect;
    if (pct >= 70) return AppStrings.result.scoreLabelGood;
    if (pct >= 50) return AppStrings.result.scoreLabelMedium;
    return AppStrings.result.scoreLabelWeak;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmall = screenWidth < _smallScreenBreakpoint;
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

        final heroHeight =
            titleLength > 42 ? _longTitleHeroHeight : _defaultHeroHeight;
        final imageHeight = isSmall ? _smallImageHeight : _defaultImageHeight;
        // Score намеренно того же размера что и titleFontSize — визуальный
        // ритм «имя и оценка равноценны», отличие только в цвете (primary).
        final percentFontSize = titleFontSize;

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
                right: _heroGlowOffsetRight,
                top: _heroGlowOffsetTop,
                child: Container(
                  width: _heroGlowSize,
                  height: _heroGlowSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.32),
                        AppColors.lavenderTint.withValues(alpha: 0.72),
                        AppColors.lavenderTint.withValues(alpha: 0.12),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: _heroImageOffsetRight,
                top: _heroImageOffsetTop,
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
                left: AppSpacing.xxxl,
                top: AppSpacing.md,
                right: screenWidth * _titleColumnRightFactor,
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
                        height: _titleLineHeight,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    if (scorePct != null) ...[
                      const SizedBox(height: AppSpacing.xxxxxl),
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
                          const SizedBox(width: AppSpacing.xxxl),
                          const _FavoritePawButton(),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _scoreLabel(scorePct),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Toggle-кнопка «в избранное» рядом с процентом в hero. Состояние локальное
/// (имитация без бэка), но сам control полноценный и tappable.
class _FavoritePawButton extends FavoritePawButton {
  const _FavoritePawButton();
}

class _ResultCharacteristicsSection extends CharacteristicsSection {
  const _ResultCharacteristicsSection({required super.attributes});
}

class _SummarySection extends SummarySection {
  const _SummarySection({required super.summary});
}

class _WhyMatchSection extends StatelessWidget {
  const _WhyMatchSection({required this.insights});

  final List<String> insights;

  @override
  Widget build(BuildContext context) {
    return _SoftSectionCard(
      icon: Icons.auto_awesome_rounded,
      child: ReasonsSection(
        title: AppStrings.result.insights,
        items: insights
            .map(
              (text) => ReasonItem(
                text: text,
                icon: Icons.check_circle_rounded,
                color: AppColors.accent,
                plainIcon: true,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _ImportantNotesSection extends StatelessWidget {
  const _ImportantNotesSection({
    required this.requirementHighlights,
    required this.influences,
  });

  final List<String> requirementHighlights;
  final List<ReasonItem> influences;

  @override
  Widget build(BuildContext context) {
    final items = <ReasonItem>[
      ...requirementHighlights.map(
        (text) => ReasonItem(
          text: text,
          icon: Icons.task_alt_rounded,
          color: AppColors.primary,
          plainIcon: true,
        ),
      ),
      ...influences,
    ];

    return _SoftSectionCard(
      icon: Icons.info_outline_rounded,
      iconColor: AppColors.primary,
      child: ReasonsSection(
        title: AppStrings.result.requirements,
        items: items,
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
              const SizedBox(height: AppSpacing.md),
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

  void _showAllSuggestions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.72,
            minChildSize: 0.52,
            maxChildSize: 0.92,
            builder: (context, scrollController) {
              final theme = Theme.of(context);
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xxl),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxxl,
                        AppSpacing.xxl,
                        AppSpacing.xxxl,
                        AppSpacing.xl,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppStrings.result.suggestionsTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xxxl,
                          0,
                          AppSpacing.xxxl,
                          AppSpacing.xxxxxl,
                        ),
                        itemCount: suggestions.length,
                        separatorBuilder:
                            (_, __) => const SizedBox(height: AppSpacing.xl),
                        itemBuilder: (context, index) {
                          final suggestion = suggestions[index];
                          return UiCard(
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                onTap(suggestion);
                              },
                              borderRadius: BorderRadius.circular(
                                AppRadius.xxl,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.xxl),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        suggestion.breedName,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xl),
                                    Text(
                                      '${((suggestion.score ?? 0) * 100).round()}%',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.result.suggestionsTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _showAllSuggestions(context),
              child: Text(AppStrings.result.suggestionsAction),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppStrings.result.suggestionsHint,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary.withValues(alpha: AppAlpha.muted),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          height: BreedStoryAvatar.estimatedHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xl),
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return BreedStoryAvatar(
                breedName: suggestion.breedName,
                score: suggestion.score ?? 0,
                imageUrl: suggestion.storyAvatarUrl ?? suggestion.imageUrl,
                onTap: () => onTap(suggestion),
              );
            },
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
      padding: const EdgeInsets.all(AppSpacing.xxxl),
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
          const SizedBox(width: AppSpacing.xl),
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
            const SizedBox(height: AppSpacing.xxl),
            Text(
              AppStrings.result.emptyTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
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
