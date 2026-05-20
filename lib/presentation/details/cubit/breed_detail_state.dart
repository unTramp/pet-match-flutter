import 'package:equatable/equatable.dart';

import '../../../core/failures.dart';
import '../../../domain/entities/breed_detail.dart';

sealed class BreedDetailState extends Equatable {
  const BreedDetailState();

  @override
  List<Object?> get props => const [];
}

final class BreedDetailInitial extends BreedDetailState {
  const BreedDetailInitial();
}

final class BreedDetailLoading extends BreedDetailState {
  const BreedDetailLoading();
}

final class BreedDetailLoaded extends BreedDetailState {
  const BreedDetailLoaded(this.detail);

  final BreedDetail detail;

  @override
  List<Object?> get props => [detail];
}

final class BreedDetailError extends BreedDetailState {
  const BreedDetailError(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}
