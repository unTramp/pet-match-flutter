import '../../domain/entities/breed_detail.dart';
import '../../domain/repositories/breed_repository.dart';
import '../mappers/breed_mapper.dart';
import '../network/dio_failure_mapper.dart';
import '../sources/petwise_remote_source.dart';

class BreedRepositoryImpl implements BreedRepository {
  BreedRepositoryImpl(this._source);

  final PetWiseRemoteSource _source;
  final Map<String, BreedDetail> _cache = <String, BreedDetail>{};

  @override
  Future<BreedDetail> getBreedDetail(String breedId) async {
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
