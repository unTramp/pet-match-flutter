import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/breed_detail.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'cubit/breed_detail_cubit.dart';
import 'cubit/breed_detail_state.dart';

class BreedDetailPage extends StatelessWidget {
  const BreedDetailPage({super.key, required this.breedId});

  final int breedId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BreedDetailCubit>(
      create: (_) => sl<BreedDetailCubit>()..load(breedId),
      child: _BreedDetailView(breedId: breedId),
    );
  }
}

class _BreedDetailView extends StatelessWidget {
  const _BreedDetailView({required this.breedId});

  final int breedId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BreedDetailCubit, BreedDetailState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('О породе')),
          body: SafeArea(
            child: switch (state) {
              BreedDetailInitial() ||
              BreedDetailLoading() => const LoadingView(),
              BreedDetailError(:final failure) => ErrorView(
                failure: failure,
                onRetry: () => context.read<BreedDetailCubit>().load(breedId),
              ),
              BreedDetailLoaded(:final detail) => _BreedDetailContent(
                detail: detail,
              ),
            },
          ),
        );
      },
    );
  }
}

class _BreedDetailContent extends StatelessWidget {
  const _BreedDetailContent({required this.detail});

  final BreedDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      physics: const BouncingScrollPhysics(),
      children: [
        if (detail.imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: CachedNetworkImage(
                imageUrl: detail.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.border),
                errorWidget: (_, __, ___) => Container(color: AppColors.border),
              ),
            ),
          ),
        const SizedBox(height: 20),
        Text(detail.breedName, style: theme.textTheme.headlineLarge),
        if (detail.summary != null) ...[
          const SizedBox(height: 8),
          Text(detail.summary!, style: theme.textTheme.bodyLarge),
        ],
        if (detail.hasGallery) ...[
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed:
                () => context.push(
                  '/breed/${detail.breedId}/gallery',
                  extra: detail.galleryImages,
                ),
            icon: const Icon(Icons.photo_library_outlined),
            label: Text('Галерея — ${detail.galleryImages.length} фото'),
          ),
        ],
        const SizedBox(height: 24),
        ...detail.sections.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(s.body, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
