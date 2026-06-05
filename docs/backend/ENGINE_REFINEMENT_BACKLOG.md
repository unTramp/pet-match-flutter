# Engine Refinement Backlog

Этот файл фиксирует **актуальный** следующий этап развития `PetWise`
matching engine после уже внедрённого foundation и `scoring v2`.

## Current State

Уже сделано и не требует повторного планирования:
- `petType` filtering и refusal для пустого пула
- directional comparators, включая `exerciseNeeds = symmetric`
- single source of truth для priority target resolution
- explainability через `contributions` и `triggeredCapReasons`
- compatibility bridge-view для клиента
- contradictory-answer handling через `profileDiagnostics`
- server hardening baseline, deploy scaffold и live backend
- `imageUrl` в breed fixtures
- retention и более устойчивый `resultId`

Статус сейчас:
- backend задеплоен и проходит live smoke test
- reference engine и backend specs покрыты тестами
- active scoring config: [scoring_config.v2.json](./config/scoring_config.v2.json)

## Next Priorities

### P1. Expand breed catalog to product-ready depth
- довести dog catalog хотя бы до `25–30` качественных профилей
- расширять набор контрастных пород, а не только популярных
- использовать repeatable ingestion pipeline, а не ad-hoc ручной импорт
- поддерживать для каждой породы:
  - нормализованные attributes
  - `imageUrl`
  - `summaryShort`, `strengths`, `watchouts`

Почему это важно:
- сейчас качество подбора больше ограничено шириной каталога, чем математикой
- это лучший ROI по [docs/CLAUDE.md](../CLAUDE.md)

Практический вектор:
- `Freeads` как `primary reviewed source`
- `pets_json` и `normalized_pets` как supplementary/media sources

### P2. Expand ranking fixtures around real user segments
- добавить `10–15` новых ranking scenarios
- покрыть сегменты:
  - very small apartment
  - family with young children
  - first-time owner
  - low-shedding priority
  - active outdoor lifestyle
  - budget-sensitive household
  - quiet companion
  - other-pets coexistence

Цель:
- сделать drift в ранжировании заметным сразу
- улучшать engine через реальные сценарии, а не через ощущения

### P3. Add example/spec contract validation as a permanent guardrail
- все JSON examples должны парситься
- examples не должны отставать от runtime contract
- при изменении response shape обновлять:
  - `openapi.yaml`
  - `docs/backend/examples/*.json`
  - contract tests

### P4. Replace placeholder breed imagery with production assets
- уйти с `placehold.co` на реальные breed images или CDN-backed assets
- при необходимости расширить каталог полями:
  - `imageUrl`
  - `galleryImages`
  - `attribution`

Это уже не core engine, но сильно влияет на доверие к Result.

### P5. Prepare calibrated AI-assisted catalog ingestion
- оставить runtime deterministic
- использовать AI только offline:
  - extraction
  - normalization
  - summary generation
- добавить review/validation pipeline перед записью в каталог

### P6. Plan cat flow as a separate scoring track
- не смешивать dog и cat semantics в одном конфиге без нужды
- сначала утвердить:
  - cat-specific attributes
  - questionnaire deltas
  - ranking fixtures

## Recommended Order

1. расширение dog catalog
2. расширение ranking fixtures
3. поддержание example/contract validation
4. реальные изображения и result presentation quality
5. AI ingestion pipeline
6. отдельный cat flow

## Guardrails

- Любое изменение поведения сначала фиксируется или обновляется в fixture.
- Все новые scoring-правила должны жить в config, а не в хардкоде.
- Перед коммитом:
  - `flutter test test/backend_specs`
  - `dart analyze backend`
- Перед деплоем:
  - локальный `flutter test test/backend_specs`
  - live smoke test через `backend/deploy/smoke-test.sh`
