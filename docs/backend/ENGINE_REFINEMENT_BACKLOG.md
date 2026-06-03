# Engine Refinement Backlog

Этот файл фиксирует следующий этап развития `PetWise` matching engine после
текущего foundation/deploy baseline.

Статус сейчас:
- backend и deploy scaffold уже собраны
- runtime backend поднят и проходит live smoke test
- reference engine и backend specs зафиксированы тестами

Следующий этап:
- повышаем корректность и объяснимость движка
- выравниваем backend contract с клиентской моделью
- не ломаем принципы V1: deterministic, explainable, calibratable, config-driven

## Priority Backlog

### P1. petType filtering and empty-pool handling
- Фильтровать каталог по `userProfile.petType`
- Для `unknown` не форсить `dog`
- Для пустого пула вернуть осмысленный результат вместо `500`

### P2. Directional comparators
- Увести часть полей с симметричной дистанции на `atLeast` / `atMost`
- Держать поведение config-driven через `scoring_config`
- Обязательно перезаписать ranking fixtures до изменения кода

### P3. Single source of truth for priority target resolution
- Убрать гидрацию derived target values из `profile_builder`
- Оставить matcher единственным местом резолва приоритетов
- Проверить, что `/questionnaire/profile` и `/match/preview` дают идентичный ranking

### P4. Better explainability
- Сохранять `triggeredCapReasons`
- Сохранять field-level contributions
- Строить `strongMatches` и `weakMatches` персонально, а не только из breed content

### P5. Contract alignment with client compatibility model
- Свести backend response к доменной модели клиента
- Добавить `score`, `risk`, `compatible`, `suggestions`, `hardReasons`, `risks`, `insights`
- Обновить `openapi.yaml` и example payloads

### P6. Contradictory-answer handling
- Не терять критерий молча при пустом пересечении allow-set
- Завести conflict flag
- Добавить мягкий cap или штраф через config

### P7. Server hardening
- CORS
- request size limit
- `Content-Type` validation
- clean analyzer state for backend module

## Recommended Order

1. `petType` filtering + empty pool
2. directional comparators + fixture re-baseline
3. priority target single-source cleanup
4. explainability extensions
5. client contract alignment
6. contradictory-answer handling
7. server hardening

## Guardrails

- Любое изменение поведения сначала фиксируется/обновляется в fixture
- Все новые правила должны жить в config, а не в хардкоде
- Перед коммитом:
  - `flutter test test/backend_specs`
  - `dart analyze backend`
