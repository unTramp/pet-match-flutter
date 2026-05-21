/// Единая таблица ключей `SharedPreferences`. Нужна, чтобы избежать
/// коллизий имён между разными модулями и упростить поиск всех write/read
/// точек одного и того же ключа.
class PrefsKeys {
  PrefsKeys._();

  /// Уникальный uuid-идентификатор анонимного клиента, под который
  /// бэк создаёт сессию (см. `SessionCache.getOrCreateUid`).
  static const String sessionUid = 'session_uid';

  /// Сохранённый `user_id`, возвращённый бэком после `POST /start`.
  /// Используется для resume-вызовов `GET /session`.
  static const String sessionUserId = 'session_user_id';
}
