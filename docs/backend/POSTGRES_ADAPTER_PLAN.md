# PetWise Postgres Adapter Plan

Этот документ фиксирует безопасный путь от текущего `file`-runtime к реальному Postgres-backed backend-у без ещё одного большого рефакторинга.

## Current state

Сейчас backend уже умеет:

- поднимать runtime отдельно от legacy `pet-match`
- читать versioned specs
- считать profile + ranking
- сохранять `match_result` в file-backed storage
- переключать persistence driver через `PETWISE_STORAGE_DRIVER`

Но `postgres` пока scaffold-only и честно падает fast-fail.

## Main constraint

Текущий backend написан внутри Flutter-репозитория и использует sync-style runtime seams:

- [questionnaire_repository.dart](/Users/andreydorofeev/Development/CLAUDE/pet-match/backend/src/repositories/questionnaire_repository.dart:1)
- [breed_repository.dart](/Users/andreydorofeev/Development/CLAUDE/pet-match/backend/src/repositories/breed_repository.dart:1)
- [scoring_config_repository.dart](/Users/andreydorofeev/Development/CLAUDE/pet-match/backend/src/repositories/scoring_config_repository.dart:1)
- [match_result_repository.dart](/Users/andreydorofeev/Development/CLAUDE/pet-match/backend/src/repositories/match_result_repository.dart:1)

Для настоящей БД это не идеально, потому что любой live query naturally async.

## Recommended strategy

Для `PetWise` я бы не тащил Prisma JS runtime внутрь этого Flutter-репозитория как production path.

Лучший practical путь сейчас:

1. Immutable config data грузить из Postgres на старте приложения в in-memory snapshot.
2. Runtime mutable state, например `match_results`, читать и писать через async adapter.
3. Когда backend отделится в отдельный repo/package, можно решить, остаёмся на native Dart Postgres или переходим на Prisma/Node ecosystem.

Это значит:

- `questionnaire definitions`
- `answer_to_profile_mappings`
- `scoring_configs`
- `breeds`
- `breed_attributes`
- `breed_content`

можно сначала загрузить один раз при bootstrap.

А вот:

- `stored_match_results`

лучше сразу проектировать как обычную runtime persistence table.

## Recommended package choice

### Preferred now

Использовать native Dart driver:

- `postgres`

Почему:

- не нужен Node runtime рядом с Dart server
- проще интегрировать в текущий репозиторий
- лучше совпадает с текущим bootstrap и Hetzner deploy shape

### Not preferred right now

Использовать Prisma JS runtime как production adapter внутри этого repo.

Почему это плохой промежуточный шаг:

- нужен отдельный JS runtime layer
- усложняется Docker image и process model
- возникнет смешанная `Flutter + Dart + Node + Prisma` среда внутри одного backend bootstrap

Prisma schema можно сохранять как data-model reference, но runtime adapter лучше делать на native Dart driver.

## Required pubspec changes

Когда перейдём к реальному adapter implementation, я бы добавил:

```yaml
dependencies:
  postgres: ^3.5.0
```

Опционально позже:

```yaml
dev_dependencies:
  test: any
```

Если backend будет вынесен в отдельный package, тогда зависимости лучше разделить и не держать их в общем Flutter `pubspec.yaml`.

## Safe implementation path

### Phase 1. Keep current repository interfaces

Ничего не ломаем в runtime API.

Что делаем:

- оставляем `file` driver рабочим
- реализуем `postgres` bootstrap только для `match_result_repository`
- immutable catalog/config пока оставляем file-backed

Польза:

- самый маленький production jump
- уже можно хранить реальные результаты в Postgres
- ranking logic не трогаем

### Phase 2. Add startup snapshot loader for immutable data

Что делаем:

- `questionnaireRepository`
- `breedRepository`
- `scoringConfigRepository`

получают Postgres-backed bootstrap loader, который один раз читает активные версии и собирает in-memory snapshot.

Важно:

- runtime service layer остаётся почти без изменений
- sync interfaces можно сохранить дольше

### Phase 3. Optional async repository cleanup

Когда backend стабилизируется:

- переводим repository contracts на `Future`
- особенно это касается runtime state repositories

Но это не обязательно делать до первой рабочей версии на Hetzner.

## Suggested DB mapping

### Immutable reference data

- `Breed`
- `BreedAttributes`
- `BreedContent`
- `QuestionnaireDefinition`
- `AnswerToProfileMapping`
- `ScoringConfig`

### Runtime state

- `StoredMatchResult`

Зачем нужен отдельный `StoredMatchResult`:

- `GET /matches/{resultId}` уже существует в API
- это естественная первая таблица для runtime persistence
- не надо ждать полной миграции всего каталога в БД

## Prisma schema note

В [schema.prisma](/Users/andreydorofeev/Development/CLAUDE/pet-match/prisma/schema.prisma:1) я уже добавил:

- `StoredMatchResult`

Это нужно, чтобы модель данных не отставала от уже существующего file-backed runtime behavior.

## What I would implement next

1. Добавить `postgres` dependency в `pubspec.yaml`.
2. Создать `backend/src/infra/persistence/postgres/postgres_match_result_repository.dart`.
3. Подключить его в `PersistenceBootstrap` только для `MatchResultRepository`.
4. Оставить questionnaire/breeds/scoring на `file` ещё на один шаг.
5. После этого проверить:
   - `POST /match/preview`
   - `GET /matches/{resultId}`
   - server startup with `PETWISE_STORAGE_DRIVER=postgres`

## Hetzner recommendation

Для первого живого запуска я бы делал так:

- `docker-compose`
- `petwise-backend`
- `postgres`
- `nginx`

И только потом думал о bare-metal `systemd`.

Причина простая:

- проще bootstrap БД
- проще env management
- проще volume lifecycle

## Decision

Лучший следующий инженерный шаг:

- не мигрировать весь catalog в Postgres сразу
- сначала подключить Postgres только для `StoredMatchResult`
- затем добавить startup snapshot loader для immutable reference data

Это даст живой прогресс без лишнего риска.
