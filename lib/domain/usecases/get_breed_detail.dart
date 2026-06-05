import '../entities/breed_detail.dart';
import '../repositories/breed_repository.dart';

class GetBreedDetail {
  GetBreedDetail(this._repository);

  final BreedRepository _repository;

  Future<BreedDetail> call(String breedId) => _repository.getBreedDetail(breedId);
}
