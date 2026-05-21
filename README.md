# Pet Match — Flutter

Android-first Flutter-приложение, воспроизводящее основной flow веб-приложения **Pet Match AI**: онбординг → анкета → анализ → рекомендация → детали породы.

## Запуск

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run                                    # mock-режим (по умолчанию)
flutter run --dart-define=USE_MOCK=false       # реальный dev API
```

Сборка APK:
```bash
flutter build apk --release
```

### Build-time флаги

| Флаг | По умолчанию | Назначение |
|---|---|---|
| `USE_MOCK` | `true` | `true` — данные из `assets/mock/`, `false` — реальный dev API |
| `API_BASE_URL` | `https://app-api.dev.pet-match.app/api/v1` | базовый URL HTTP-источника |
| `MOCK_FAIL_RATE` | `0` | 0..1 — вероятность сетевой ошибки в mock-режиме (для ручной проверки retry-flow) |

Пример:
```bash
flutter run --dart-define=USE_MOCK=false \
            --dart-define=API_BASE_URL=https://app-api.dev.pet-match.app/api/v1
```

## Архитектура

Чистая 3-слойная Clean Architecture: `data` / `domain` / `presentation` + сквозной `core`. Направление зависимостей: `presentation → domain ← data`. Domain не знает ни о Flutter, ни о Dio — только чистый Dart.

```
lib/
├── core/            DI, network (dio + interceptors), cache, theme, failures, logger
├── data/            DTO (json_serializable), mappers, sources (Http + Mock), repositories
├── domain/          entities, repositories (abstract), use cases
└── presentation/    router (go_router), screens, cubits, widgets
```

Подробное описание архитектуры — в приложенном **`docs/architecture.pdf`**.
Карта соответствия ТЗ — **[docs/tz-compliance.md](docs/tz-compliance.md)**.

### Ключевые решения

- **State management — Cubit** (`flutter_bloc`). Линейный flow без сложных реактивных цепочек: Cubit = Bloc без Events, меньше boilerplate, проще ревьюить.
- **Sealed `Question`** — `SingleChoiceQuestion` / `MultipleChoiceQuestion` / `DynamicOptionsQuestion`. UI делает `switch` exhaustively — забыть тип в presentation невозможно (compile error, а не runtime).
- **Sealed `AppFailure`** — `NetworkFailure` / `TimeoutFailure` / `ServerFailure(code, message)` / `EmptyResponseFailure`. Каждый тип ошибки осмысленно обрабатывается отдельно.
- **Polling на `/analyzing`** — `PollCompatibility` use case опрашивает `GET /session` каждые 1.5s пока `compatibility.status != ready`, timeout 30s.
- **`RetryInterceptor`** в dio — 3 попытки, exponential backoff 1s → 2s → 4s, только для `connectionError` и timeout-ов. Server 4xx/5xx не ретраются.
- **Resume сессии** — `uid` и `user_id` хранятся в `SharedPreferences`. Router redirect ловит активную сессию и уводит сразу на `/questionnaire`, минуя welcome/intro.
- **Mock-first** — `MockPetMatchRemoteSource` реализует тот же интерфейс, что и `HttpPetMatchRemoteSource`. Включён по умолчанию (`USE_MOCK=true`). Удобен для демо без сети и для тестов без мокания HTTP.

## Тесты

```bash
flutter test
```

Покрыты:

1. **`question_mapper_test.dart`** — конвертация DTO → sealed `Question`: `single_choice`, `multiple_choice`, `dynamic_options`, `search_select` (имя из реального API), unknown fallback, exclusive_option_codes из `config_json`.
2. **`compatibility_mapper_test.dart`** — нормализация score (integer 0..100 из реала vs фракция 0..1 из мока) и парсинг status (`ready` / `completed` / `processing` / unknown).
3. **`questionnaire_repository_test.dart`** — маппинг `DioException` → `AppFailure` + success-кейсы (с `mocktail`).
4. **`poll_compatibility_test.dart`** — polling success / timeout / network error через `fake_async`.
5. **`questionnaire_cubit_test.dart`** — state-машина: start/submit/skip/retry + exclusive-option логика в `toggleMulti` (`bloc_test`).
6. **`questionnaire_page_test.dart`** — Loading / Question / Error состояния UI, ProgressBar, SingleChoiceWidget.
7. **`result_page_test.dart`** — `MainBreedCard` + `SuggestionCard` рендер + tap.
8. **`error_view_test.dart`** — сообщение по типу `AppFailure` + Retry callback.

Всего **47** тестов (минимум по ТЗ — 2-3).

## Реальный API — проверено end-to-end

Базовый URL: `https://app-api.dev.pet-match.app/api/v1` (публичный, без auth). Прогон сделан `curl`-ом по 27 вопросам (адаптивная анкета — `total_questions_count` растёт по мере раскрытия scope'ов).

Покрытые отличия от первоначальной разведки и фиксы:
- **`stats.answered_questions_count` / `stats.total_questions_count`** (а не `*_count`) — `StatsDto` поддерживает оба варианта.
- **`question_type: "search_select"`** в реале (вместо ожидаемого `dynamic_options`) — `QuestionMapper` маппит оба в `DynamicOptionsQuestion`.
- **`compatibility.status: "completed"`** (а не `"ready"`) — `CompatibilityMapper` понимает оба.
- **`score` приходит как integer 0..100** (а не фракция 0..1, как в моке) — нормализуется к единому виду 0..1.
- **`multiple_choice` exclusive options** — поле `config_json.exclusive_option_codes` читается в `MultipleChoiceQuestion.exclusiveOptionCodes`; `QuestionnaireCubit.toggleMulti` гарантирует на клиенте что exclusive-опция не может быть выбрана вместе с обычными (избегаем 400 от сервера).

## Mock-фикстуры

`assets/mock/`:
- `questions.json` — 6 вопросов: 4× single-choice, 1× multiple-choice, 1× dynamic-options (опциональный).
- `dynamic_options_preferred_breed.json` — 10 пород для поиска (фильтрация по `q` работает).
- `compatibility_processing.json` / `compatibility_ready.json` — `MockPetMatchRemoteSource` сначала отдаёт processing, потом ready (имитация polling).
- `breed_<id>.json` — детали + галерея для нескольких пород.

## Осознанные упрощения

- **Локализация UI** — строки захардкожены на русском. API сам возвращает локализованный контент через `?locale=ru` (`LocaleInterceptor` добавляет автоматически). ARB-файлы не добавлены — для тестового задания не оценивается, а время съело бы прирост по архитектуре.
- **Анимации переходов** — стандартные go_router. Кастомных slide/fade между вопросами нет.
- **Галерея** — `PageView` + `InteractiveViewer` для pinch-to-zoom. Нет Hero-анимаций.
- **Offline-режим** — только in-memory кеш для `BreedDetail`. Полноценного offline нет: ответы анкеты живут на сервере (мы их не дублируем локально).
- **Аналитика (`POST /events`)** — не реализована, ТЗ не требует.
- **iOS** — не настраивался (per ТЗ Android-first).
- **CI** — не настроен (по решению заказчика).
- **Accessibility** — базовые Flutter-семантики. Кастомных focus-orders и TalkBack-меток нет.
- **freezed** — не используется (вместо неё plain классы + `json_serializable`). Причина: в текущем Flutter SDK (3.29.3 + Dart 3.7.2) freezed builder уходит в zombie-state из-за бага в `analyzer`. Plain DTO + равенство через `Equatable` в domain — рабочая и достаточная альтернатива для тестового задания.

## Следующие шаги при большем времени

- Hive / Drift для персистентного кеша всей сессии и полного offline-first.
- Lottie на экране Analyzing, AnimatedSwitcher между вопросами, Hero для изображений пород.
- Golden tests для ключевых виджетов (`MainBreedCard`, `SuggestionCard`, `ErrorView`).
- CI/CD: GitHub Actions с `flutter analyze` + `flutter test` + `flutter build apk` на каждый PR.
- Accessibility: Semantics на все интерактивные элементы, поддержка TalkBack.
- `POST /events` — аналитика просмотров.

## Итог

Архитектура построена так, чтобы её центральные элементы были compile-time-гарантированы: типы вопросов, типы ошибок, состояния cubit'ов — всё через sealed-классы. Cubit отвечает только за async-логику и state, виджеты — только за рендер. Каждый тип ошибки имеет своё сообщение и retry. Слой `domain` не зависит от Flutter — реализацию репозитория можно подменить на mock без правок UI.
