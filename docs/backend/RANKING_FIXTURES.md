# PetWise Ranking Fixtures

Этот файл описывает, как использовать ranking fixtures для проверки `Matching V1`.

## Purpose

Ranking fixtures нужны, чтобы проверять не только валидность схем, но и здравость результата:

- корректно ли работает `scoring_config`
- не ломают ли изменения в `breed catalog` ожидаемый ranking
- не дают ли критические критерии неадекватно высокие результаты

## Fixture shape

Каждый fixture содержит:

- `fixtureId`
- `description`
- `questionnaireVersion`
- `scoringVersion`
- `inputUserProfile`
- `expected`

## Recommended assertions

Для V1 не стоит тестировать абсолютный `matchPercent` слишком жестко. Лучше проверять:

- `expected.topBreedId`
- `expected.topMatchPercentRange`
- `expected.acceptableTop3`
- `expected.mustRankAbove`

## Why relative assertions are better

Если позже слегка поменяются веса или один атрибут в breed catalog, точный процент может измениться на `1-3` пункта, но правильный порядок останется тем же. Поэтому ranking tests должны в первую очередь ловить:

- неправильный top result
- критически странные перестановки
- провал caps по детям / квартире / другим животным
- ложные штрафы за “избыточно хороший” fit после directional comparators

## Current fixtures

- [ranking_case.apartment_quiet_beginner.json](./examples/ranking_case.apartment_quiet_beginner.json)
- [ranking_case.active_trainable.json](./examples/ranking_case.active_trainable.json)
- [ranking_case.family_friendly.json](./examples/ranking_case.family_friendly.json)
- [ranking_case.house_yard_quiet_beginner.json](./examples/ranking_case.house_yard_quiet_beginner.json)
- [ranking_case.apartment_low_shedding_trainable.json](./examples/ranking_case.apartment_low_shedding_trainable.json)
- [ranking_case.small_calm_apartment.json](./examples/ranking_case.small_calm_apartment.json)
- [ranking_case.low_shedding_small_family.json](./examples/ranking_case.low_shedding_small_family.json)
- [ranking_case.tiny_apartment_budget.json](./examples/ranking_case.tiny_apartment_budget.json)
- [ranking_case.active_family_house.json](./examples/ranking_case.active_family_house.json)
- [ranking_case.active_grooming_spaniel.json](./examples/ranking_case.active_grooming_spaniel.json)
- [ranking_case.large_guardian_house.json](./examples/ranking_case.large_guardian_house.json)

## Executable reference spec

Чтобы fixtures не оставались только документацией, рядом есть исполняемый reference test:

- [../../test/backend_specs/reference_matcher_fixture_test.dart](../../test/backend_specs/reference_matcher_fixture_test.dart)

Он читает:

- `catalog.v1.json`
- `scoring_config.v2.json`
- `ranking_case*.json`

И проверяет:

- ожидаемый top breed
- допустимый диапазон top score
- membership в acceptable top-3
- относительный порядок для `mustRankAbove`

## Manual usage

Прогнать только тестовые assertions:

```bash
flutter test test/backend_specs/reference_matcher_fixture_test.dart
```

Посмотреть ranking для одного fixture:

```bash
HOME=/private/tmp DART_SUPPRESS_ANALYTICS=true dart run tool/backend_specs/run_reference_matcher.dart --fixture apartment_quiet_beginner --top 5
```

Посмотреть ranking для произвольного `user_profile.json`:

```bash
HOME=/private/tmp DART_SUPPRESS_ANALYTICS=true dart run tool/backend_specs/run_reference_matcher.dart --profile-json path/to/user_profile.json --top 5
```

`HOME=/private/tmp` и `DART_SUPPRESS_ANALYTICS=true` полезны для локального tool-runner сценария, чтобы Dart не пытался писать telemetry в домашнюю директорию среды.
