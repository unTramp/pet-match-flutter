# Import Candidates

Эта папка хранит **черновые import artifacts** для расширения breed catalog
из внешних источников вроде `pets_json` и `Freeads`.

Это не production catalog и не runtime fixtures.

Задача этих файлов:
- сохранить нормализованный source snapshot
- подготовить media/content для будущего импорта
- отделить content-ready данные от scoring attributes, которые ещё требуют review

## File format

Каждый `candidate.*.json` содержит:
- `breedId`
- `petType`
- `name`
- `source`
- `mediaDraft`
- `contentDraft`
- `attributeExtractionHints`
- `importStatus`
- `quality`

## Important rules

- Эти кандидаты **не** должны автоматически попадать в `catalog.v1.json`
- `attributes` и `flags` здесь намеренно не считаются каноническими
- Всё, что касается scoring, должно проходить отдельный review

## Phase 1 candidates

Первый пакет с лучшим ROI:
- `maltese`
- `pug`
- `jack_russell_terrier`
- `english_cocker_spaniel`
- `doberman`

Эти файлы генерируются автоматически из:
- `pets_json`
- `normalized_pets`
- [phase1_manifest.json](./phase1_manifest.json)

Команда:

```bash
python3 tool/backend_specs/generate_import_candidates.py
```

## Freeads foundation

Для нового основного source теперь есть отдельный foundation layer:
- [freeads_phase1_manifest.v1.json](./freeads_phase1_manifest.v1.json)
- [freeads_phase2_manifest.v1.json](./freeads_phase2_manifest.v1.json)
- [freeads_full_manifest.v1.json](./freeads_full_manifest.v1.json)
- [freeads_slug_mapping.v1.json](./freeads_slug_mapping.v1.json)
- [freeads_raw/README.md](./freeads_raw/README.md)
- [freeads_review_pack/README.md](./freeads_review_pack/README.md)

Генератор:

```bash
python3 tool/backend_specs/generate_freeads_candidates.py
```

Review pack:

```bash
python3 tool/backend_specs/generate_freeads_review_pack.py
```

Full registry + current catalog mapping:

```bash
python3 tool/backend_specs/generate_freeads_registry.py
```

Важно:
- `Freeads` candidates тоже не идут напрямую в `catalog.v1.json`
- сначала сохраняется raw snapshot
- затем собирается `candidate.*.json`
- затем строится `review.<breedId>.json`
- и только после review появляется canonical `breed.*.json`

## Current status

Первая волна уже поднята в канонический каталог:
- `maltese`
- `pug`
- `jack_russell_terrier`
- `english_cocker_spaniel`
- `doberman`

Вторая волна уже поднята в канонический каталог:
- `yorkshire_terrier`
- `american_cocker_spaniel`
- `rottweiler`

`Freeads` pilot review wave уже тоже полностью закрыта:
- `maltese`
- `pug`
- `english_cocker_spaniel`
- `american_cocker_spaniel`
- `rottweiler`
- `yorkshire_terrier`
- `jack_russell_terrier`
- `doberman`

Финальные `breed.*.json` для них собраны semi-assisted поверх:
- template breed fixture
- `pets_json`
- `normalized_pets`

## Next step

Для следующих batch-ей:
1. сгенерировать новый candidate snapshot
2. выбрать template breed baseline
3. собрать финальный `breed.*.json`
4. прогнать `validate_catalog`
5. только потом добавлять породу в `catalog.v1.json`
