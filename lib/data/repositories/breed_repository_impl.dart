import 'package:dio/dio.dart';

import '../../core/failures.dart';
import '../../domain/entities/breed_detail.dart';
import '../../domain/repositories/breed_repository.dart';
import '../mappers/breed_mapper.dart';
import '../sources/pet_match_remote_source.dart';

class BreedRepositoryImpl implements BreedRepository {
  BreedRepositoryImpl(this._source);

  final PetMatchRemoteSource _source;
  final Map<int, BreedDetail> _cache = <int, BreedDetail>{};

  @override
  Future<BreedDetail> getBreedDetail(int breedId) async {
    final cached = _cache[breedId];
    if (cached != null) return cached;
    try {
      final dto = await _source.getBreedDetail(breedId: breedId);
      final entity = BreedMapper.fromDto(dto);
      _cache[breedId] = entity;
      return entity;
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw const TimeoutFailure();
        case DioExceptionType.connectionError:
          throw const NetworkFailure();
        case DioExceptionType.badResponse:
        case DioExceptionType.cancel:
        case DioExceptionType.badCertificate:
        case DioExceptionType.unknown:
          throw ServerFailure(
            statusCode: e.response?.statusCode ?? 0,
            message: e.message ?? 'Unknown error',
          );
      }
    }
  }
}
