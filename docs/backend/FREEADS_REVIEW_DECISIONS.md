# Freeads Review Decisions

Этот документ фиксирует reviewed решения по `Freeads` pilot batch.

Задача:
- не переписывать canonical catalog автоматически по новому source
- а использовать `Freeads` как structured review layer там, где он реально
  улучшает каталог

## Current source quality

Сейчас у нас уже есть `browser-captured` signal для:
- `maltese`
- `pug`
- `english_cocker_spaniel`
- `american_cocker_spaniel`
- `jack_russell_terrier`
- `yorkshire_terrier`
- `rottweiler`

Остаётся в `needs_browser_capture` только:
- `doberman`

Это важно, потому что browser-captured source сильнее прежнего snippet-level
слоя, но всё равно не считается auto-truth для scoring-sensitive полей вроде
`aloneTolerance` или `goodWithChildren`.

## Reviewed breeds

### `maltese`

Решение:
- numeric attributes не менять
- content переписать под более честный low-shedding / grooming-heavy profile
- provenance усилить через `freeads browser capture review`

Почему:
- `sheddingLevelDraft = 1` хорошо совпадает с canonical
- `groomingNeedsDraft = 1` конфликтует с практической реальностью породы и не
  выглядит надёжной основой для engine rewrite
- `exerciseNeedsDraft = 3` и `aloneToleranceDraft = 4` полезны как reviewer
  signal, но пока слишком смелы для прямого numeric обновления

Итог:
- canonical values оставлены как есть
- summary/result copy стал правдоподобнее
- confidence и provenance повышены

### `pug`

Решение:
- `sheddingLevel` повышен `4 -> 5`
- content чуть уточнён под calmer home rhythm и сильную линьку
- provenance усилить через `freeads browser capture review`

Почему:
- browser-captured `Heavy` для shedding выглядит правдоподобно и хорошо
  совпадает с реальным бытовым опытом породы
- это как раз high-ROI поле: у нас есть questionnaire по линьке, и ошибка здесь
  напрямую ухудшает matching UX
- `aloneToleranceDraft = 5` по-прежнему не считаем достаточным основанием для
  переписывания engine-поля, потому что label `Very calm` не равен “любит
  одиночество”

Итог:
- один бытово значимый numeric field уточнён
- content/result copy стал честнее
- confidence и provenance повышены

### `english_cocker_spaniel`

Решение:
- дополнительные numeric changes сейчас не делать
- ранее внесённые изменения считать подтверждёнными browser capture:
  - `exerciseNeeds 3 -> 4`
  - `temperamentCalm 4 -> 3`
- provenance усилить через `freeads browser capture review`

Почему:
- browser data подтверждает уже сделанный active / grooming-heavy сдвиг:
  - `exerciseNeedsDraft = 5`
  - `trainabilityDraft = 5`
  - `groomingNeedsDraft = 5`
- новые drifts по `aloneTolerance` и `maintenanceCost` пока не выглядят
  достаточно надёжными для автоматического пересмотра canonical engine-полей

Итог:
- canonical profile остаётся сильным и выглядит подтверждённым более качественным
  source
- confidence и provenance повышены

### `rottweiler`

Решение:
- numeric attributes не менять
- content переписать под более честный large-working profile
- provenance усилить через `freeads browser capture review`

Почему:
- `Freeads` хорошо подтверждает already-strong canonical baseline:
  - `exerciseNeedsDraft = 5`
  - `trainabilityDraft = 5`
  - `maintenanceCostDraft = 5`
- все numeric отличия находятся в зоне `near_match`, а не в зоне явного
  пересмотра модели
- зато current content был слишком generic и даже внутренне спорным:
  `умеренный уровень активности` плохо сочетается с `exerciseNeeds = 5`

Итог:
- engine math оставлена стабильной
- result/details copy стала заметно правдоподобнее
- confidence и provenance повышены

### `american_cocker_spaniel`

Решение:
- `sheddingLevel` повышен `3 -> 5`
- content переписать под более честный energetic / grooming-heavy spaniel profile
- provenance усилить через `freeads browser capture review`

Почему:
- browser-captured `Very heavy` для shedding выглядит достаточно сильным и
  practically important signal
- это хорошо совпадает с тем, что порода уже и так описана как grooming-heavy,
  но раньше в canonical profile линька была недооценена
- `aloneToleranceDraft = 4` и `maintenanceCostDraft = 3` пока не считаем
  достаточными основаниями для numeric rewrite

Итог:
- один бытово значимый numeric field уточнён
- spaniel branch стала лучше разведена по content/result UX
- confidence и provenance повышены

## Current policy

На текущем этапе `Freeads` используется так:
- browser-captured source сильнее snippet-level source
- numeric changes допускаются только при явной продуктовой пользе
- content/provenance updates допускаются шире
- labels вроде `Calm`, `Very calm`, `Low anxiety` не считаются прямой заменой
  для `aloneTolerance`
- taxonomy mismatches (`gun_dog` vs `sporting`) требуют human review, а не
  автоматической перезаписи
