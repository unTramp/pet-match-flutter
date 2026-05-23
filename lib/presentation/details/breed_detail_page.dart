import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/components/animated_score_label.dart';
import '../../core/design/components/ui_button.dart';
import '../../core/design/content/app_strings.dart';
import '../../core/design/tokens/alpha.dart';
import '../../core/design/tokens/shadows.dart';
import '../../core/design/tokens/sizes.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/di/injection.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/breed_detail.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
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

  final int breedId;

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

  final int breedId;
  final double? score;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BreedDetailCubit, BreedDetailState>(
      builder: (context, state) {
        return Scaffold(
          body: switch (state) {
            BreedDetailInitial() || BreedDetailLoading() => const SafeArea(
              child: LoadingView(),
            ),
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
    const bleed = AppSpacing.lg;

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
            top: media.padding.top + AppSpacing.sm,
            left: AppSpacing.lg,
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
    final url = detail.imageUrl;
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
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        physics: const BouncingScrollPhysics(),
        children: [
          Text(detail.breedName, style: theme.textTheme.headlineLarge),
          if (score != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _ScoreBadge(score: score!),
          ],
          if (summary != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(summary, style: theme.textTheme.bodyLarge),
          ],
          if (detail.hasGallery) ...[
            const SizedBox(height: AppSpacing.xl),
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
          const SizedBox(height: AppSpacing.xxl),
          for (var i = 0; i < sections.length; i++) ...[
            Text(sections[i].title, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(sections[i].body, style: theme.textTheme.bodyLarge),
            if (i < sections.length - 1) ...[
              const SizedBox(height: AppSpacing.xl),
              Divider(
                color: AppColors.border.withValues(alpha: AppAlpha.divider),
                height: 1,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ],
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
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
        const SizedBox(width: AppSpacing.sm),
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
