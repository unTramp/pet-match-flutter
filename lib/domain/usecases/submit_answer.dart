import '../entities/answer.dart';
import '../entities/session.dart';
import '../repositories/questionnaire_repository.dart';

class SubmitAnswer {
  SubmitAnswer(this._repository);

  final QuestionnaireRepository _repository;

  Future<Session> call({required int userId, required UserAnswer answer}) =>
      _repository.submitAnswer(userId: userId, answer: answer);
}
