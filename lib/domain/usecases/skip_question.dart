import '../entities/session.dart';
import '../repositories/questionnaire_repository.dart';

class SkipQuestion {
  SkipQuestion(this._repository);

  final QuestionnaireRepository _repository;

  Future<Session> call({required int userId, required int questionId}) =>
      _repository.skipQuestion(userId: userId, questionId: questionId);
}
