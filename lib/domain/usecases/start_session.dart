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
    final savedUserId = await _cache.getSavedUserId();
    final session =
        savedUserId != null
            ? await _repository.getSession(savedUserId)
            : await () async {
              final uid = await _cache.getOrCreateUid();
              return _repository.startSession('uid:$uid');
            }();
    await _cache.saveUserId(session.userId);
    return session;
  }
}
