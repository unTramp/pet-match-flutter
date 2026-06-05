import '../entities/breed_detail.dart';

abstract class BreedRepository {
  Future<BreedDetail> getBreedDetail(String breedId);
}
