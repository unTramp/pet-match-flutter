import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/components/animated_score_label.dart';
import '../../core/design/components/ui_button.dart';
import '../../core/design/content/app_strings.dart';
import '../../core/design/tokens/alpha.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/shadows.dart';
import '../../core/design/tokens/sizes.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/di/injection.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/breed_detail.dart';
import '../../domain/entities/breed_flags.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../result/widgets/reasons_section.dart';
import '../result/widgets/characteristics_section.dart';
import 'cubit/breed_detail_cubit.dart';
import 'cubit/breed_detail_state.dart';

/// Полноэкранный экран деталей породы.
///
/// Использует edge-to-edge hero-image + плоскую вёрстку контента поверх
/// scaffold-фона (без вложенной white card). Если переход пришёл с
/// result-экрана через `GoRoute.extra` со score — рендерим animated
/// match-badge. Для deep-link `/breed/:id` без extra бейдж скрыт.
class BreedDetailPage extends StatelessWidget {
  const BreedDetailPage({super.key, required this.breedId, this.score});

  final String breedId;

  /// Опциональный match score (0..1), прокинутый с Result через extra.
  /// Если null — секция совпадения не рендерится.
  final double? score;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BreedDetailCubit>(
      create: (_) => sl<BreedDetailCubit>()..load(breedId),
      child: _BreedDetailView(breedId: breedId, score: score),
    );
  }
}

class _BreedDetailView extends StatelessWidget {
  const _BreedDetailView({required this.breedId, required this.score});

  final String breedId;
  final double? score;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BreedDetailCubit, BreedDetailState>(
      builder: (context, state) {
        return Scaffold(
          body: switch (state) {
            BreedDetailInitial() ||
            BreedDetailLoading() => const SafeArea(child: LoadingView()),
            BreedDetailError(:final failure) => SafeArea(
              child: ErrorView(
                failure: failure,
                onRetry: () => context.read<BreedDetailCubit>().load(breedId),
              ),
            ),
            BreedDetailLoaded(:final detail) => _LoadedBody(
              detail: detail,
              score: score,
            ),
          },
        );
      },
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.detail, required this.score});

  final BreedDetail detail;
  final double? score;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Hero занимает ≈42% экрана, content начинается на `bleed` выше нижнего
    // края image — лёгкая перекрышка без rounded-corner card.
    final heroHeight = media.size.height * 0.42;
    const bleed = AppSpacing.xxl;

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
          label: AppStrings.details.ctaBack,
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: heroHeight,
            child: _HeroImage(detail: detail),
          ),
          Positioned.fill(
            top: heroHeight - bleed,
            child: _Content(detail: detail, score: score),
          ),
          Positioned(
            top: media.padding.top + AppSpacing.md,
            left: AppSpacing.xxl,
            child: const _FloatingBackButton(),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.detail});

  final BreedDetail detail;

  @override
  Widget build(BuildContext context) {
    final url = detail.storyAvatarUrl ?? detail.imageUrl;
    final placeholder = Container(
      color: AppColors.lavenderTint,
      alignment: Alignment.center,
      child: const Icon(
        Icons.pets_rounded,
        size: AppIconSize.hero,
        color: AppColors.primary,
      ),
    );

    return Hero(
      tag: 'breed_image_${detail.breedId}',
      child:
          url == null
              ? placeholder
              : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.border),
                errorWidget: (_, __, ___) => placeholder,
              ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.detail, required this.score});

  final BreedDetail detail;
  final double? score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = detail.sections;
    final summary = detail.summary;
    final hasFlags = detail.flags != null && !detail.flags!.isEmpty;
    final hasKeyTraits = (detail.group?.isNotEmpty ?? false) || hasFlags;
    return DecoratedBox(
      // Лёгкий fade сверху, чтобы граница image/cream не была резкой.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.04],
          colors: [AppColors.cream.withValues(alpha: 0), AppColors.cream],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxxl,
          AppSpacing.xxxl,
          AppSpacing.xxxl,
          AppSpacing.xxxl,
        ),
        physics: const BouncingScrollPhysics(),
        children: [
          Text(detail.breedName, style: theme.textTheme.headlineLarge),
          if (score != null) ...[
            const SizedBox(height: AppSpacing.md),
            _ScoreBadge(score: score!),
          ],
          if (summary != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(summary, style: theme.textTheme.bodyLarge),
          ],
          if (hasKeyTraits) ...[
            const SizedBox(height: AppSpacing.xxxl),
            _KeyTraitsSection(detail: detail),
          ],
          if (detail.attributes case final attributes?
              when !attributes.isEmpty) ...[
            const SizedBox(height: AppSpacing.xxxl),
            CharacteristicsSection(attributes: attributes),
          ],
          if (detail.hasGallery) ...[
            const SizedBox(height: AppSpacing.xxxl),
            UiButton(
              onPressed:
                  () => context.push(
                    AppRoutes.breedGallery(detail.breedId),
                    extra: detail.galleryImages,
                  ),
              icon: Icons.photo_library_outlined,
              variant: UiButtonVariant.secondary,
              label:
                  '${AppStrings.details.galleryLabelPrefix} — '
                  '${detail.galleryImages.length} '
                  '${AppStrings.details.photosSuffix}',
            ),
          ],
          const SizedBox(height: AppSpacing.xxxxl),
          for (var i = 0; i < sections.length; i++) ...[
            _DetailSection(section: sections[i]),
            if (i < sections.length - 1) ...[
              const SizedBox(height: AppSpacing.xxxl),
              Divider(
                color: AppColors.border.withValues(alpha: AppAlpha.divider),
                height: 1,
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ],
          const SizedBox(height: AppSpacing.xxxxl),
        ],
      ),
    );
  }
}

class _KeyTraitsSection extends StatelessWidget {
  const _KeyTraitsSection({required this.detail});

  final BreedDetail detail;

  @override
  Widget build(BuildContext context) {
    final chips = <_TraitChipData>[
      if (detail.group case final group? when group.isNotEmpty)
        _TraitChipData(
          label: _groupLabel(group),
          background: AppColors.lavenderTint,
          foreground: AppColors.primaryDark,
        ),
      ..._flagChips(detail.flags),
    ];

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ключевые особенности', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: chips
              .map(
                (chip) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: chip.background,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    chip.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: chip.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }

  static String _groupLabel(String group) => switch (group) {
    'sporting' => 'Спортивная группа',
    'working' => 'Рабочая группа',
    'herding' => 'Пастушья группа',
    'hound' => 'Гончая группа',
    'toy' => 'Той-группа',
    'terrier' => 'Терьер',
    'non-sporting' => 'Компаньон',
    'utility' => 'Утилитарная группа',
    _ => group,
  };

  static List<_TraitChipData> _flagChips(BreedFlags? flags) {
    if (flags == null || flags.isEmpty) {
      return const [];
    }

    return [
      if (flags.isSuitableForFirstTimeOwners)
        const _TraitChipData(
          label: 'Подходит новичкам',
          background: AppColors.lavenderTint,
          foreground: AppColors.primaryDark,
        ),
      if (flags.isVocal)
        const _TraitChipData(
          label: 'Голосистая',
          background: AppColors.warningSurface,
          foreground: AppColors.warning,
        ),
      if (flags.isHighPreyDrive)
        const _TraitChipData(
          label: 'Сильный prey drive',
          background: AppColors.warningSurface,
          foreground: AppColors.warning,
        ),
      if (flags.isSensitive)
        const _TraitChipData(
          label: 'Чувствительная',
          background: AppColors.lavenderTint,
          foreground: AppColors.primaryDark,
        ),
      if (flags.isEscapeProne)
        const _TraitChipData(
          label: 'Склонна к побегам',
          background: AppColors.warningSurface,
          foreground: AppColors.warning,
        ),
    ];
  }
}

class _TraitChipData {
  const _TraitChipData({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.section});

  final BreedSection section;

  @override
  Widget build(BuildContext context) {
    final title = section.title.trim();
    final lines = section.body
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    if (lines.isEmpty) {
      return const SizedBox.shrink();
    }

    final config = switch (title) {
      'Сильные стороны' => (
        icon: Icons.check_circle_rounded,
        color: AppColors.accent,
      ),
      'Что учитывать' => (
        icon: Icons.warning_amber_rounded,
        color: AppColors.warning,
      ),
      'Советы по адаптации' => (
        icon: Icons.tips_and_updates_rounded,
        color: AppColors.primary,
      ),
      _ => (icon: Icons.notes_rounded, color: AppColors.primary),
    };

    return ReasonsSection(
      title: title,
      items: lines
          .map(
            (line) => ReasonItem(
              text: line,
              icon: config.icon,
              color: config.color,
              plainIcon: true,
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        AnimatedScoreLabel(
          score: score,
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 36,
            color: AppColors.primary,
            height: 1.0,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Text(
            AppStrings.details.matchBadge,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _FloatingBackButton extends StatelessWidget {
  const _FloatingBackButton();

  @override
  Widget build(BuildContext context) {
    const size = AppControlSize.tapTarget;
    return Semantics(
      button: true,
      label: AppStrings.details.backSemantic,
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: () => context.pop(),
          radius: size / 2,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              boxShadow: AppShadows.card,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: AppIconSize.lg,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
