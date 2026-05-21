/// Единый таймаут для пользовательских запросов: prefetch на welcome/intro,
/// submit/skip/start внутри questionnaire-cubit, receiveTimeout у Dio.
/// `connectTimeout`/`sendTimeout` остаются отдельными — у них другой смысл.
const Duration kRequestTimeout = Duration(seconds: 15);

/// Debounce для поиска динамических опций в анкете.
const Duration kSearchDebounce = Duration(milliseconds: 400);

/// Имя приложения в task-switcher'е и Material accessibility hints.
/// Отдельно от `AppStrings.common.appBrand` (тот — стилизованный uppercase лого).
const String kAppTitle = 'Pet Match AI';
