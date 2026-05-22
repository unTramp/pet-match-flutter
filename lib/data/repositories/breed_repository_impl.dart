import '../../domain/entities/breed_detail.dart';
import '../../domain/repositories/breed_repository.dart';
import '../mappers/breed_mapper.dart';
import '../network/dio_failure_mapper.dart';
import '../sources/pet_match_remote_source.dart';

class BreedRepositoryImpl implements BreedRepository {
  BreedRepositoryImpl(this._source);

  final PetMatchRemoteSource _source;
  final Map<int, BreedDetail> _cache = <int, BreedDetail>{};

  @override
  Future<BreedDetail> getBreedDetail(int breedId) async {
    final cached = _cache[breedId];
    if (cached != null) return cached;
    return guardCall(() async {
      final dto = await _source.getBreedDetail(breedId: breedId);
      final entity = BreedMapper.fromDto(dto);
      _cache[breedId] = entity;
      return entity;
    });
  }
}
