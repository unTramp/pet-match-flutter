abstract interface class MatchResultRepository {
  Future<void> save(Map<String, dynamic> result);

  Future<Map<String, dynamic>?> getById(String resultId);
}
