import '../entities/answer.dart';
import '../entities/option.dart';
import '../entities/session.dart';

/// Контракт data-слоя для questionnaire-операций.
///
/// Все методы могут бросать [AppFailure] — типизированные сетевые/бизнес-ошибки.
/// Никаких `DioException` наружу не уходит.
abstract class QuestionnaireRepository {
  Future<Session> startSession(String externalId);

  Future<Session> getSession(int userId);

  Future<Session> submitAnswer({
    required int userId,
    required UserAnswer answer,
  });

  Future<Session> skipQuestion({required int userId, required int questionId});

  Future<List<DynamicOption>> getDynamicOptions({
    required int userId,
    required int questionId,
    String? query,
  });
}
