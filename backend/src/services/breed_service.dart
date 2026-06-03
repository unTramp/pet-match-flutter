import '../repositories/breed_repository.dart';

class BreedService {
  BreedService(this._repository);

  final BreedRepository _repository;

  Map<String, dynamic>? getBreed(String breedId) =>
      _repository.getBreedById(breedId);
}
