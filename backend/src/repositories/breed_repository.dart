import '../domain/spec_models.dart';

abstract interface class BreedRepository {
  Map<String, dynamic>? getBreedById(String breedId);

  List<BreedFixture> listBreedFixtures();
}
