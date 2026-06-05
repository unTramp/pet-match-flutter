# Freeads Review Decisions

Этот документ фиксирует **первые reviewed решения** по `Freeads` pilot batch.

Задача:
- не переписывать canonical catalog автоматически по новому source
- а аккуратно использовать `Freeads` как review layer там, где он реально
  помогает улучшить каталог

## Reviewed breeds

### `maltese`

Решение:
- numeric attributes не менять
- provenance усилить через `freeads snippet review`

Почему:
- `sheddingLevelDraft = 1` хорошо совпадает с canonical
- но `groomingNeedsDraft = 1` конфликтует с практической реальностью породы
- `exerciseNeedsDraft = 3` и `aloneToleranceDraft = 4` пока выглядят слишком
  смело для snippet-level source

Итог:
- canonical values оставлены как есть
- confidence и source provenance повышены

### `pug`

Решение:
- numeric attributes не менять
- content сделать точнее
- provenance усилить через `freeads snippet review`

Почему:
- по ключевым бытовым полям `Freeads` в целом близок к canonical
- но `aloneToleranceDraft = 5` выглядит слишком сильной интерпретацией label-а
  `Calm`
- зато source хорошо подсвечивает shedding и помогает улучшить result/details
  copy

Итог:
- canonical values оставлены как есть
- summary/watchouts/adaptationTips уточнены
- confidence и source provenance повышены

### `english_cocker_spaniel`

Решение:
- `exerciseNeeds` повышен `3 -> 4`
- `temperamentCalm` снижен `4 -> 3`
- content полностью переписан под более активный и grooming-heavy профиль
- provenance усилить через `freeads snippet review`

Почему:
- current canonical description был слишком “квартирный и спокойный”
- `Freeads` дал устойчивый signal:
  - `exerciseNeedsDraft = 5`
  - `trainabilityDraft = 5`
  - `groomingNeedsDraft = 5`
- это лучше совпадает с ожидаемым образом активной spaniel-породы

Итог:
- canonical profile стал правдоподобнее для ranking и result UX

## Current policy

На текущем этапе `Freeads` используется так:
- numeric changes допускаются только при явной продуктовой пользе
- content/provenance updates допускаются шире
- snippet-level source не считается достаточным для агрессивной массовой
  перезаписи каталога
