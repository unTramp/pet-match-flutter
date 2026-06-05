# Freeads Ingestion Plan

Этот документ фиксирует pragmatic rollout для миграции breed catalog на
`Freeads` как основной внешний source.

## Goal

Построить repeatable pipeline:
- `Freeads index -> raw snapshots -> candidate artifacts -> reviewed breed fixtures`

без упрощения текущего engine под ограничения внешнего источника.

## Scope

На первом этапе:
- только `dog`
- только offline ingestion
- без автоматической записи в `catalog.v1.json`
- с учётом того, что direct `curl` fetch breed pages может упираться в
  Cloudflare challenge

## Phases

### Phase 0. Source foundation

Deliverables:
- [FREEADS_MAPPING_SPEC.md](./FREEADS_MAPPING_SPEC.md)
- pilot manifest с первыми породами
- raw snapshot schema
- candidate generator

Success criteria:
- у нас есть repeatable format для `Freeads` artifacts
- мы не смешиваем raw source и canonical breed fixtures

### Phase 1. Pilot batch

Первая волна:
- `maltese`
- `pug`
- `yorkshire_terrier`
- `jack_russell_terrier`
- `english_cocker_spaniel`
- `american_cocker_spaniel`
- `rottweiler`
- `doberman`

Deliverables:
- raw snapshots по каждой породе
- `candidate.*.json`
- initial review notes

Success criteria:
- из `Freeads` можно стабильно получать content/media/draft traits
- candidate format подходит для reviewer workflow

### Phase 2. Catalog backfill

Переоценить уже существующие dog breeds через `Freeads`:
- не обязательно переписывать всё сразу
- сначала те породы, где текущий контент слабый или placeholder-like

Success criteria:
- у существующего каталога становится единообразнее provenance
- images/content становятся более consistent

### Phase 3. Breadth expansion

Дальше уже расширяем dog catalog за пределы текущих `26` пород через тот же
pipeline.

## Guardrails

- `Freeads` не пишет напрямую в canonical breed fixtures.
- Все scoring-sensitive поля проходят review.
- Любая новая canonical порода проходит:
  - `dart run tool/backend_specs/validate_catalog.dart`
  - `flutter test test/backend_specs`
- Runtime backend остаётся deterministic.

## Recommended Next Step

Практически следующий шаг после foundation:
1. положить первые raw snapshots в `docs/backend/import_candidates/freeads_raw`
2. прогнать `generate_freeads_candidates.py`
3. проверить candidate outputs
4. выбрать первые `3-5` пород для reviewed import

### Note about collection

На практике raw snapshots, скорее всего, нужно собирать:
- через browser-assisted copy/save
- или через отдельный scraper, умеющий проходить JS/Cloudflare challenge

Обычный `curl` для breed pages сейчас не стоит считать надёжным ingestion path.
