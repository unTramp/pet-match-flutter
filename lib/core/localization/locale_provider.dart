import 'dart:ui';

/// Поставщик текущей локали приложения. Используется как
/// `LocaleInterceptor`, так и `MaterialApp`. Сейчас отдаёт фиксированный
/// `ru` (единственный поддерживаемый язык UI), но интерфейс готов под
/// смену через настройки пользователя без переписывания интерсептора.
abstract class LocaleProvider {
  Locale get current;

  /// Двухбуквенный код для API-параметра `?locale=`.
  String get apiCode => current.languageCode;
}

class StaticLocaleProvider implements LocaleProvider {
  const StaticLocaleProvider(this._locale);

  final Locale _locale;

  @override
  Locale get current => _locale;

  @override
  String get apiCode => _locale.languageCode;
}
