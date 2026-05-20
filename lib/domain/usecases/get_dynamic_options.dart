import '../entities/option.dart';
import '../repositories/questionnaire_repository.dart';

class GetDynamicOptions {
  GetDynamicOptions(this._repository);

  final QuestionnaireRepository _repository;

  Future<List<DynamicOption>> call({
    required int userId,
    required int questionId,
    String? query,
  }) => _repository.getDynamicOptions(
    userId: userId,
    questionId: questionId,
    query: query,
  );
}
