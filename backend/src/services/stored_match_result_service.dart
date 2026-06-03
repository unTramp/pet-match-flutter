import '../repositories/match_result_repository.dart';

class StoredMatchResultService {
  const StoredMatchResultService(this._repository);

  final MatchResultRepository _repository;

  Future<Map<String, dynamic>?> getById(String resultId) =>
      _repository.getById(resultId);
}
