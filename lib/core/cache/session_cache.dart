import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SessionCache {
  SessionCache({SharedPreferences? prefs, Uuid? uuid})
    : _prefs = prefs,
      _uuid = uuid ?? const Uuid();

  static const _uidKey = 'session_uid';
  static const _userIdKey = 'session_user_id';

  SharedPreferences? _prefs;
  final Uuid _uuid;

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<String> getOrCreateUid() async {
    final prefs = await _instance;
    final existing = prefs.getString(_uidKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final newUid = _uuid.v4();
    await prefs.setString(_uidKey, newUid);
    return newUid;
  }

  Future<int?> getSavedUserId() async {
    final prefs = await _instance;
    return prefs.getInt(_userIdKey);
  }

  Future<void> saveUserId(int id) async {
    final prefs = await _instance;
    await prefs.setInt(_userIdKey, id);
  }

  Future<bool> hasActiveSession() async => (await getSavedUserId()) != null;

  Future<void> clearSession() async {
    final prefs = await _instance;
    await prefs.remove(_uidKey);
    await prefs.remove(_userIdKey);
  }
}
