/// Пути REST API сервиса `api_app`. Совпадают с OpenAPI-схемой
/// https://app-api.dev.pet-match.app/openapi.json.
///
/// Базовый URL задаётся отдельно через `API_BASE_URL` build-flag
/// (`core/di/injection.dart`), здесь хранятся только относительные пути.
class Endpoints {
  Endpoints._();

  static const String startSession = '/questionnaire/start';

  static String userSession(int userId) =>
      '/questionnaire/users/$userId/session';

  static String userAnswers(int userId) =>
      '/questionnaire/users/$userId/answers';

  static String skipQuestion(int userId, int questionId) =>
      '/questionnaire/users/$userId/questions/$questionId/skip';

  static String questionOptions(int userId, int questionId) =>
      '/questionnaire/users/$userId/questions/$questionId/options';

  static String breedDetail(int breedId) => '/questionnaire/breeds/$breedId';
}
