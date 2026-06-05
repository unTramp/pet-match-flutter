# Flutter Switch Checklist

Этот файл фиксирует практический порядок перевода Flutter-приложения
на новый `PetWise` backend.

Использовать после завершения migration-ветки и перед финальным merge/release.

## Goal

Подтвердить, что приложение:

- использует новый backend contract
- проходит основной пользовательский flow
- корректно переживает ошибки и повторные входы
- не сломало `Result`, `Details` и `Gallery`

## Current Technical Baseline

Уже готово:

- новый backend задеплоен
- Flutter data layer переведён на `PetWise` source
- local questionnaire session adapter реализован
- `breedId` мигрирован на `String`
- `flutter analyze` проходит
- `flutter test` проходит

## Step 1. Local Code Health

Перед ручной проверкой:

1. `flutter analyze`
2. `flutter test`

Ожидаемый результат:

- нет analyzer issues
- все tests зелёные

## Step 2. Manual App Smoke

Проверить руками в приложении:

### A. Welcome / Intro

- открывается `Welcome`
- бренд/иконки отображаются корректно
- CTA ведёт в `Intro`
- переходы визуально стабильны

### B. Questionnaire Start

- анкета стартует без legacy session loading-loop
- первый вопрос отображается сразу после загрузки definition
- верхний бар скрыт на questionnaire
- progress bar показывает адекватный прогресс

### C. Questionnaire Main Flow

Проверить:

- single choice работает
- multi choice работает
- `maxSelections` реально ограничивает выбор
- optional question можно skip-нуть
- после 8 вопроса refinement gate ведёт себя корректно

Проверить оба сценария:

1. пользователь не идёт в optional block
2. пользователь идёт в optional block

### D. Resume / Restart

- закрыть приложение посреди анкеты
- открыть снова
- draft answers корректно восстановлены
- restart flow очищает локальный draft

### E. Analyzing / Result

- после последнего вопроса показывается `Analyzing`
- нет бесконечной загрузки
- открывается `Result`
- статичный top bar отображается стабильно
- карточка основной породы, suggestions и characteristics отображаются корректно
- trait icons реально подгружаются

### F. Breed Details / Gallery

- переход из `Result` в `Details` работает
- строковый `breedId` корректно используется в роутинге
- `Details` грузит данные с нового backend
- `Gallery` открывается и показывает изображения

## Step 3. Error Smoke

Проверить хотя бы один сценарий на ошибку:

- временно указать неверный `API_BASE_URL`
  или
- отключить сеть на устройстве/эмуляторе

Проверить:

- questionnaire loading не зависает навсегда
- error state рендерится явно
- retry работает

## Step 4. Backend Runtime Smoke

Подтвердить, что app ходит именно в live backend:

- `GET /questionnaire/definition`
- `POST /questionnaire/profile`
- `POST /match/preview`
- `GET /breeds/{breedId}`

Быстрые признаки:

- app получает вопросы из актуального definition
- result приходит с текущим `scoringVersion`
- breed details совпадают с live catalog

## Step 5. Commit Strategy

Если smoke успешен:

1. коммит migration switch
2. отдельный коммит на UI/asset restore, если нужно держать историю чище

Рекомендованные commit messages:

- `feat(app): switch questionnaire flow to petwise backend`
- `refactor(ui): restore brand assets and simplify top bars`

## Step 6. Post-Switch Priorities

После успешного switch не делать новый большой refactor.

Следующий backlog по ROI:

1. расширять dog catalog
2. добавлять ranking fixtures под реальные user segments
3. улучшать real breed imagery/content
4. потом переходить к cat flow

## Release Decision

Можно считать switch успешным, если:

- `flutter analyze` зелёный
- `flutter test` зелёный
- manual smoke пройден
- app показывает result с live backend
- details/gallery работают
- error/retry не ломают flow
