import 'package:flutter/foundation.dart';

enum AppLanguage {
  ru('ru'),
  en('en');

  const AppLanguage(this.code);

  final String code;
}

class AppLocaleController extends ValueNotifier<AppLanguage> {
  AppLocaleController._() : super(AppLanguage.ru);

  static final AppLocaleController instance = AppLocaleController._();

  AppLanguage get current => value;

  void setLanguage(AppLanguage language) {
    if (value == language) return;
    value = language;
  }
}
