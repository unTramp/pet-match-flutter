# Freeads Pilot Comparison

Этот документ фиксирует текущее состояние `Freeads` pilot batch и показывает,
насколько source уже полезен для валидации существующего каталога.

## Current pilot batch

Всего в pilot batch сейчас `8` пород:
- `maltese`
- `pug`
- `yorkshire_terrier`
- `jack_russell_terrier`
- `english_cocker_spaniel`
- `american_cocker_spaniel`
- `rottweiler`
- `doberman`

Из них:
- `3` уже имеют snippet-level structured signal
- `5` пока только `index_verified_only`

Machine-readable review pack лежит в:
- [import_candidates/freeads_review_pack/summary.v1.json](./import_candidates/freeads_review_pack/summary.v1.json)
- [import_candidates/freeads_review_pack](./import_candidates/freeads_review_pack)

## What Freeads already gives us

### Strongest current candidates

#### `maltese`

Уже есть useful draft signal:
- `exerciseNeedsDraft = 3`
- `sheddingLevelDraft = 1`
- `groomingNeedsDraft = 1`
- `goodWithChildrenDraft = 2`
- `maintenanceCostDraft = 2`
- `aloneToleranceDraft = 4`

Практический смысл:
- source уже помогает валидировать compact low-shedding companion profile
- особенно полезен для review по бытовой совместимости и уходу

#### `pug`

Уже есть useful draft signal:
- `sizeDraft = 2`
- `exerciseNeedsDraft = 3`
- `sheddingLevelDraft = 5`
- `groomingNeedsDraft = 3`
- `goodWithChildrenDraft = 3`
- `maintenanceCostDraft = 3`
- `aloneToleranceDraft = 5`

Практический смысл:
- source хорошо подтверждает mainstream small-companion profile
- уже даёт явный сигнал по shedding и относительной терпимости к одиночеству

Главный drift сейчас:
- `aloneTolerance`: canonical `2` vs Freeads draft `5`

Это не значит, что `Freeads` автоматически прав, а значит, что тут нужен
целенаправленный review.

#### `english_cocker_spaniel`

Уже есть useful draft signal:
- `exerciseNeedsDraft = 5`
- `trainabilityDraft = 5`
- `sheddingLevelDraft = 3`
- `groomingNeedsDraft = 5`
- `goodWithChildrenDraft = 3`
- `maintenanceCostDraft = 3`
- `aloneToleranceDraft = 4`
- aliases + health tests

Практический смысл:
- `Freeads` уже неплохо поддерживает spaniel-family branch
- это хороший кандидат для следующего reviewed pass

### Remaining five

Пока только `index_verified_only`:
- `yorkshire_terrier`
- `jack_russell_terrier`
- `american_cocker_spaniel`
- `rottweiler`
- `doberman`

Практический смысл:
- pipeline для них уже есть
- identity и source URLs уже нормализованы
- но полноценный comparison пока ограничен отсутствием richer raw snapshot

## Main conclusion

Даже на текущем уровне `Freeads` уже полезен:
- как provenance-rich validation layer
- как structured trait draft
- как источник factual metadata

Но bottleneck сейчас уже не в маппинге, а в source capture.

Следующий сильный шаг:
1. добрать richer raw snapshots для оставшихся `5`
2. прогнать review pack повторно
3. и только потом обновлять canonical `breed.*.json`
