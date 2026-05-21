import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/prefs_keys.dart';

enum AppLanguage {
  ru('ru'),
  en('en');

  const AppLanguage(this.code);

  final String code;

  static AppLanguage? fromCode(String? code) {
    for (final lang in AppLanguage.values) {
      if (lang.code == code) return lang;
    }
    return null;
  }
}

/// Глобальный контроллер выбора языка. UI читает текущее значение через
/// `instance.current` или подписывается через `ValueListenableBuilder`.
/// Выбор персистится в `SharedPreferences` под ключом `_prefsKey`.
class AppLocaleController extends ValueNotifier<AppLanguage> {
  AppLocaleController._({SharedPreferences? prefs})
    : _prefs = prefs,
      super(AppLanguage.ru);

  static final AppLocaleController instance = AppLocaleController._();

  static const _prefsKey = PrefsKeys.appLanguage;

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _resolvedPrefs async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Подтягивает сохранённый язык из prefs. Вызывать в `main()` до `runApp`.
  /// Дефолт — `AppLanguage.ru`, если значения нет или оно невалидное.
  Future<void> init() async {
    final prefs = await _resolvedPrefs;
    final saved = AppLanguage.fromCode(prefs.getString(_prefsKey));
    if (saved != null && saved != value) {
      value = saved;
    }
  }

  AppLanguage get current => value;

  Future<void> setLanguage(AppLanguage language) async {
    if (value == language) return;
    value = language;
    final prefs = await _resolvedPrefs;
    await prefs.setString(_prefsKey, language.code);
  }

  /// Для тестов: позволяет инжектировать мокированный SharedPreferences.
  @visibleForTesting
  static AppLocaleController debugCreate({required SharedPreferences prefs}) {
    return AppLocaleController._(prefs: prefs);
  }
}
