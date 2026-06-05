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
- `8` уже имеют `verified_via_browser_capture`

Machine-readable review pack лежит в:
- [import_candidates/freeads_review_pack/summary.v1.json](./import_candidates/freeads_review_pack/summary.v1.json)
- [import_candidates/freeads_review_pack](./import_candidates/freeads_review_pack)

## What Freeads already gives us

### Strong browser-captured confirmations

#### `maltese`

Практический смысл:
- source хорошо подтверждает very-low-shedding profile
- но одновременно показывает, что `Freeads` нельзя слепо принимать за истину
  по `groomingNeeds`

Главный вывод:
- numeric rewrite не нужен
- provenance/content rewrite полезен

#### `pug`

Практический смысл:
- source подтверждает small-companion profile
- даёт сильный и правдоподобный signal по тяжёлой линьке

Главный вывод:
- это хороший пример, где browser-captured `Freeads` уже оправдывает точечный
  numeric change

#### `english_cocker_spaniel`

Практический смысл:
- source подтверждает уже сделанный active / grooming-heavy сдвиг
- хорошо поддерживает sporting/spaniel branch

Главный вывод:
- browser capture здесь скорее подтверждает канонический профиль, чем требует
  нового engine rewrite

### Strong next review candidates

#### `american_cocker_spaniel`

Уже видно важные сигналы:
- `exerciseNeedsDraft = 5`
- `groomingNeedsDraft = 5`
- `sheddingLevelDraft = 5`
- `goodWithChildrenDraft = 3`

Практический смысл:
- хороший кандидат для следующего reviewed pass
- особенно полезен для разведения spaniel-ветки

#### `rottweiler`

Уже видно важные сигналы:
- `sizeDraft = 4`
- `exerciseNeedsDraft = 5`
- `trainabilityDraft = 5`
- `goodWithChildrenDraft = 2`
- `maintenanceCostDraft = 5`

Практический смысл:
- сильный source для large guardian / working branch

#### `jack_russell_terrier`

Уже видно важные сигналы:
- `sizeDraft = 2`
- `exerciseNeedsDraft = 5`
- `trainabilityDraft = 5`
- `sheddingLevelDraft = 3`
- `groomingNeedsDraft = 2`

Практический смысл:
- помогает честно развести активную small-dog ветку

## Main conclusion

Сейчас bottleneck уже не в source capture как таковом:
- browser-assisted pipeline доказал, что данные можно получать повторяемо
- review pack уже полезен по всему pilot batch

Следующий product step:
1. reviewed pass по `rottweiler`
2. reviewed pass по `american_cocker_spaniel`
3. reviewed pass по `yorkshire_terrier` / `jack_russell_terrier`
4. reviewed pass по `doberman`
