import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/failures.dart';
import '../../../domain/usecases/get_breed_detail.dart';
import 'breed_detail_state.dart';

class BreedDetailCubit extends Cubit<BreedDetailState> {
  BreedDetailCubit(this._getBreedDetail) : super(const BreedDetailInitial());

  final GetBreedDetail _getBreedDetail;

  Future<void> load(int breedId) async {
    emit(const BreedDetailLoading());
    try {
      final detail = await _getBreedDetail(breedId);
      emit(BreedDetailLoaded(detail));
    } on AppFailure catch (f) {
      emit(BreedDetailError(f));
    }
  }
}
