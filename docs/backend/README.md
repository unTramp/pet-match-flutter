# PetWise Backend Docs

Этот каталог фиксирует backend-контракты и рабочие спецификации для `Matching V1`.

## Files

- [DECISIONS.md](./DECISIONS.md) — зафиксированные продуктовые и архитектурные решения для V1.
- [openapi.yaml](./openapi.yaml) — черновой API-контракт для questionnaire/profile/match/breeds.
- [DATA_MODEL.md](./DATA_MODEL.md) — канонические сущности, таблицы и правила хранения данных.
- [SCORING_CONFIG.md](./SCORING_CONFIG.md) — правила расчета score, caps, boosts и версии scoring config.
- [MODULE_LAYOUT.md](./MODULE_LAYOUT.md) — рекомендуемая декомпозиция backend-модулей.
- [POSTGRES_ADAPTER_PLAN.md](./POSTGRES_ADAPTER_PLAN.md) — безопасный план подключения живого Postgres adapter.
- [EXAMPLES.md](./EXAMPLES.md) — обзор example payload-ов.
- [RANKING_FIXTURES.md](./RANKING_FIXTURES.md) — сценарии для проверки ожидаемого ranking-а.
- [PETS_JSON_MAPPING_AUDIT.md](./PETS_JSON_MAPPING_AUDIT.md) — правила, что можно безопасно забирать из внешнего `pets_json` каталога.
- [PETS_JSON_IMPORT_SHORTLIST.md](./PETS_JSON_IMPORT_SHORTLIST.md) — shortlist и порядок импорта новых пород из внешнего каталога.
- [FREEADS_MAPPING_SPEC.md](./FREEADS_MAPPING_SPEC.md) — правила маппинга `Freeads` breed pages в `PetWise` candidate format.
- [FREEADS_INGESTION_PLAN.md](./FREEADS_INGESTION_PLAN.md) — phased rollout для `Freeads` как основного внешнего source.
- [FREEADS_AVATAR_REGISTRY_PLAN.md](./FREEADS_AVATAR_REGISTRY_PLAN.md) — plan для полного slug/media registry и story avatar layer.
- [FREEADS_SOURCE_STATUS.md](./FREEADS_SOURCE_STATUS.md) — статус доступности `Freeads` data по pilot batch.
- [FREEADS_PILOT_COMPARISON.md](./FREEADS_PILOT_COMPARISON.md) — актуальная сводка по `Freeads` pilot batch и comparison workflow.
- [FREEADS_REVIEW_DECISIONS.md](./FREEADS_REVIEW_DECISIONS.md) — первые reviewed решения по породам из `Freeads` pilot batch.
- [FREEADS_CAPTURE_QUEUE.md](./FREEADS_CAPTURE_QUEUE.md) — очередь на следующий цикл richer source capture.
- [FREEADS_BROWSER_CAPTURE_PROTOCOL.md](./FREEADS_BROWSER_CAPTURE_PROTOCOL.md) — безопасный протокол для ручного browser-assisted capture.
- [import_candidates/freeads_phase2_manifest.v1.json](./import_candidates/freeads_phase2_manifest.v1.json) — следующий expansion batch после завершённого pilot cycle.
- [import_candidates/freeads_full_manifest.v1.json](./import_candidates/freeads_full_manifest.v1.json) — полный registry breed slug-ов и source image URL из внешнего CSV.
- [import_candidates/freeads_slug_mapping.v1.json](./import_candidates/freeads_slug_mapping.v1.json) — mapping текущих canonical `PetWise` пород на `Freeads` slug-и и avatar files.
- [config/answer_to_profile_mapping.v1.json](./config/answer_to_profile_mapping.v1.json) — канонический mapping `answer -> user_profile`.
- [config/scoring_config.v2.json](./config/scoring_config.v2.json) — versioned scoring config для текущего engine baseline.
- [../../prisma/schema.prisma](../../prisma/schema.prisma) — Prisma-черновик модели данных.
- [../../test/backend_specs/reference_matcher_fixture_test.dart](../../test/backend_specs/reference_matcher_fixture_test.dart) — исполняемый reference matcher spec поверх JSON fixtures.
- [../../tool/backend_specs/reference_matcher.dart](../../tool/backend_specs/reference_matcher.dart) — reusable reference matcher module.
- [../../tool/backend_specs/run_reference_matcher.dart](../../tool/backend_specs/run_reference_matcher.dart) — CLI-утилита для ручного прогона ranking fixtures и arbitrary profile JSON.
- [../../tool/backend_specs/catalog_validator.dart](../../tool/backend_specs/catalog_validator.dart) — reusable validator для breed catalog.
- [../../tool/backend_specs/validate_catalog.dart](../../tool/backend_specs/validate_catalog.dart) — CLI-утилита для проверки catalog/spec consistency.
- [../../tool/backend_specs/mapping_validator.dart](../../tool/backend_specs/mapping_validator.dart) — reusable validator для questionnaire definition и answer mapping.
- [../../tool/backend_specs/validate_mapping.dart](../../tool/backend_specs/validate_mapping.dart) — CLI-утилита для проверки questionnaire/mapping consistency.
- [../../tool/backend_specs/profile_builder.dart](../../tool/backend_specs/profile_builder.dart) — reference builder для `answers -> user_profile`.
- [../../tool/backend_specs/build_profile.dart](../../tool/backend_specs/build_profile.dart) — CLI-утилита для ручной сборки профиля из ответов.
- [../../tool/backend_specs/generate_import_candidates.py](../../tool/backend_specs/generate_import_candidates.py) — генератор черновых import candidates из `pets_json` и `normalized_pets`.
- [../../tool/backend_specs/capture_freeads_html.py](../../tool/backend_specs/capture_freeads_html.py) — browser-assisted сбор HTML breed pages из `Freeads`.
- [../../tool/backend_specs/parse_freeads_html.py](../../tool/backend_specs/parse_freeads_html.py) — преобразование сохранённого `Freeads` HTML в raw snapshot JSON.
- [../../tool/backend_specs/generate_freeads_candidates.py](../../tool/backend_specs/generate_freeads_candidates.py) — генератор черновых import candidates из raw `Freeads` snapshots.
- [../../tool/backend_specs/generate_freeads_review_pack.py](../../tool/backend_specs/generate_freeads_review_pack.py) — генератор review pack `canonical vs Freeads candidate`.
- [../../tool/backend_specs/generate_freeads_registry.py](../../tool/backend_specs/generate_freeads_registry.py) — генератор полного Freeads slug/media registry и mapping для текущего каталога.
- [../../tool/backend_specs/sync_story_avatars.py](../../tool/backend_specs/sync_story_avatars.py) — sync текущих mapped story avatar `.webp` в `backend/media/story-avatars`.
- [import_candidates/README.md](./import_candidates/README.md) — описание candidate-артефактов перед попаданием в канонический каталог.
- [../../backend](/Users/andreydorofeev/Development/CLAUDE/pet-match/backend:1) — первый живой server-side skeleton поверх reference pipeline.
- [../../backend/deploy](/Users/andreydorofeev/Development/CLAUDE/pet-match/backend/deploy:1) — deploy scaffold для Hetzner.

## Example payloads

- [examples/breed.whippet.json](./examples/breed.whippet.json)
- [examples/user_profile.apartment_quiet.json](./examples/user_profile.apartment_quiet.json)
- [examples/questionnaire_definition.v1.json](./examples/questionnaire_definition.v1.json)
- [examples/match_result.whippet.json](./examples/match_result.whippet.json)
- [examples/ranking_case.apartment_quiet_beginner.json](./examples/ranking_case.apartment_quiet_beginner.json)
- [examples/ranking_case.active_trainable.json](./examples/ranking_case.active_trainable.json)
- [examples/ranking_case.family_friendly.json](./examples/ranking_case.family_friendly.json)
- [examples/ranking_case.house_yard_quiet_beginner.json](./examples/ranking_case.house_yard_quiet_beginner.json)
- [examples/ranking_case.apartment_low_shedding_trainable.json](./examples/ranking_case.apartment_low_shedding_trainable.json)
- [examples/ranking_case.small_calm_apartment.json](./examples/ranking_case.small_calm_apartment.json)
- [examples/ranking_case.low_shedding_small_family.json](./examples/ranking_case.low_shedding_small_family.json)
- [examples/ranking_case.tiny_apartment_budget.json](./examples/ranking_case.tiny_apartment_budget.json)
- [examples/ranking_case.active_family_house.json](./examples/ranking_case.active_family_house.json)

## Scope

- `dog` flow only
- deterministic ranking
- scoring v2 with symmetric `exerciseNeeds` and narrowed conflict-cap triggers
- directional comparators for one-sided fit fields
- compatibility bridge-view on top of internal `topMatch/alternatives` result shape
- contradictory questionnaire answers degrade confidence via `profileDiagnostics`
- current dog catalog: `37` breeds, including Freeads-backed mini-batches and earlier semi-assisted imports
- AI only for offline breed enrichment and text generation
- `Freeads` accepted as a primary reviewed source for dog breed ingestion
- story avatars are served from `/media/story-avatars/{fileName}`
- config-driven questionnaire, mapping and scoring

## Quick start

Проверить, что ranking fixtures проходят:

```bash
flutter test test/backend_specs/reference_matcher_fixture_test.dart
```

Посмотреть reference ranking вручную:

```bash
HOME=/private/tmp DART_SUPPRESS_ANALYTICS=true dart run tool/backend_specs/run_reference_matcher.dart --fixture family_friendly --top 5
```

Проверить полный spec pipeline `answers -> profile -> ranking`:

```bash
flutter test test/backend_specs/end_to_end_flow_test.dart
```

Проверить breed catalog:

```bash
HOME=/private/tmp DART_SUPPRESS_ANALYTICS=true dart run tool/backend_specs/validate_catalog.dart
```

Пересобрать черновые import candidates из внешнего каталога:

```bash
python3 tool/backend_specs/generate_import_candidates.py
```

Собрать HTML breed page через обычный браузер и затем распарсить его:

```bash
python3 tool/backend_specs/capture_freeads_html.py --breed-id rottweiler
python3 tool/backend_specs/parse_freeads_html.py --breed-id rottweiler
```

Сгенерировать `candidate.*.json` из raw `Freeads` snapshots:

```bash
python3 tool/backend_specs/generate_freeads_candidates.py
```

Собрать полный Freeads slug/media registry и mapping текущего каталога:

```bash
python3 tool/backend_specs/generate_freeads_registry.py
```

Подтянуть текущие mapped story avatar `.webp` в backend media directory:

```bash
python3 tool/backend_specs/sync_story_avatars.py --source-dir /absolute/path/to/webp_512
```

Собрать review pack для текущего pilot batch:

```bash
python3 tool/backend_specs/generate_freeads_review_pack.py
```

Собрать финальные `breed.*.json` из candidate snapshot и template breed baseline:

```bash
python3 tool/backend_specs/generate_phase1_breed_fixtures.py --manifest docs/backend/import_candidates/phase2_manifest.json
```

Проверить questionnaire и answer mapping:

```bash
HOME=/private/tmp DART_SUPPRESS_ANALYTICS=true dart run tool/backend_specs/validate_mapping.dart
```

Собрать `user_profile` из answer payload:

```bash
HOME=/private/tmp DART_SUPPRESS_ANALYTICS=true dart run tool/backend_specs/build_profile.dart --answers-json docs/backend/examples/answers.apartment_quiet_beginner.json
```
