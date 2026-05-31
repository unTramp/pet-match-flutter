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
  static const double _topBarScrollThreshold = 6;

  bool _showTopBar = true;
  double _lastScrollOffset = 0;
  late final AnimationController _introController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: AppMotion.heroIntro,
    );
    _scrollController = ScrollController()..addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _introController.forward(from: 0);
    });
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset.clamp(0.0, double.infinity);
    final delta = offset - _lastScrollOffset;

    if (offset <= AppSpacing.sm) {
      if (!_showTopBar) {
        setState(() => _showTopBar = true);
      }
      _lastScrollOffset = offset;
      return;
    }

    if (delta > _topBarScrollThreshold && _showTopBar) {
      setState(() => _showTopBar = false);
    } else if (delta < -_topBarScrollThreshold && !_showTopBar) {
      setState(() => _showTopBar = true);
    }

    _lastScrollOffset = offset;
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
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
            ClipRect(
              child: AnimatedSize(
                duration: AppMotion.normal,
                curve: AppMotion.standardCurve,
                alignment: Alignment.topCenter,
                child: Align(
                  heightFactor: _showTopBar ? 1 : 0,
                  alignment: Alignment.topCenter,
                  child: AnimatedSlide(
                    duration: AppMotion.normal,
                    curve: AppMotion.standardCurve,
                    offset: _showTopBar ? Offset.zero : const Offset(0, -1),
                    child: AnimatedOpacity(
                      duration: AppMotion.fast,
                      curve: AppMotion.standardCurve,
                      opacity: _showTopBar ? 1 : 0,
                      child: TopBrandBar(
                        onLogoTap: () => context.go(AppRoutes.welcome),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: _scrollController,
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
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          0,
                        ),
                        child: _SummarySection(summary: primary!.summary!),
                      ),
                    ),
                  AppStaggeredEntrance(
                    controller: _introController,
                    interval: const Interval(0.16, 0.56),
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.xxl,
                        AppSpacing.xl,
                        0,
                      ),
                      child: _ResultCharacteristicsSection(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xxl,
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
                left: AppSpacing.xl,
                top: AppSpacing.sm,
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
                      const SizedBox(height: AppSpacing.xxxl),
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
                          const SizedBox(width: AppSpacing.xl),
                          const _FavoritePawButton(),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _scoreLabel(scorePct),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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
  const _ResultCharacteristicsSection();
}

class _SummarySection extends SummarySection {
  const _SummarySection({required super.summary});
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
                    const SizedBox(height: AppSpacing.sm),
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
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.xl,
                        AppSpacing.md,
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
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.xxxl,
                        ),
                        itemCount: suggestions.length,
                        separatorBuilder:
                            (_, __) => const SizedBox(height: AppSpacing.md),
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
                                padding: const EdgeInsets.all(AppSpacing.lg),
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
                                    const SizedBox(width: AppSpacing.md),
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
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: BreedStoryAvatar.estimatedHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return BreedStoryAvatar(
                breedName: suggestion.breedName,
                score: suggestion.score ?? 0,
                imageUrl: suggestion.imageUrl,
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
