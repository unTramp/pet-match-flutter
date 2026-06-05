import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../storage/prefs_keys.dart';

class QuestionnaireDraftCache {
  QuestionnaireDraftCache({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<Map<String, dynamic>?> load() async {
    final prefs = await _instance;
    final raw = prefs.getString(PrefsKeys.questionnaireDraft);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    return decoded;
  }

  Future<void> save(Map<String, dynamic> draft) async {
    final prefs = await _instance;
    await prefs.setString(PrefsKeys.questionnaireDraft, jsonEncode(draft));
  }

  Future<void> clear() async {
    final prefs = await _instance;
    await prefs.remove(PrefsKeys.questionnaireDraft);
  }
}
