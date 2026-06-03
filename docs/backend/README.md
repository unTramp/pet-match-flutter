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
- current dog catalog: `23` breeds, including the first semi-assisted import wave from `pets_json`
- AI only for offline breed enrichment and text generation
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

Проверить questionnaire и answer mapping:

```bash
HOME=/private/tmp DART_SUPPRESS_ANALYTICS=true dart run tool/backend_specs/validate_mapping.dart
```

Собрать `user_profile` из answer payload:

```bash
HOME=/private/tmp DART_SUPPRESS_ANALYTICS=true dart run tool/backend_specs/build_profile.dart --answers-json docs/backend/examples/answers.apartment_quiet_beginner.json
```
