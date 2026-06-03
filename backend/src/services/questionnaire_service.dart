import '../repositories/questionnaire_repository.dart';

class QuestionnaireService {
  QuestionnaireService(this._repository);

  final QuestionnaireRepository _repository;

  Map<String, dynamic> getDefinition() => _repository.getActiveDefinition();
}
