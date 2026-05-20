import '../../core/cache/session_cache.dart';
import '../entities/session.dart';
import '../repositories/questionnaire_repository.dart';

/// Стартует или возобновляет анкету. Берёт `uid` из локального кеша
/// (если нет — генерирует), вызывает POST /start, кеширует `user_id` для
/// последующих запросов и продолжения сессии после перезапуска.
class StartSession {
  StartSession(this._repository, this._cache);

  final QuestionnaireRepository _repository;
  final SessionCache _cache;

  Future<Session> call() async {
    final uid = await _cache.getOrCreateUid();
    final session = await _repository.startSession('uid:$uid');
    await _cache.saveUserId(session.userId);
    return session;
  }
}
