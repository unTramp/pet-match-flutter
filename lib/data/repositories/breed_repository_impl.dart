import 'package:dio/dio.dart';

import '../../core/failures.dart';
import '../../core/logger.dart';
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
    } on AppFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    } catch (e, st) {
      appLogger.e('BreedRepository parse error: $e', stackTrace: st);
      throw ServerFailure(statusCode: -1, message: 'Parse error: $e');
    }
  }
}

AppFailure _mapDio(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const TimeoutFailure();
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return ServerFailure(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message ?? 'Unknown error',
      );
  }
}
