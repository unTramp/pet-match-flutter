# Freeads Mapping Spec

Этот документ фиксирует, как использовать
`https://www.freeads.co.uk/dog-breeds`
как основной внешний источник для расширения dog catalog в `PetWise`.

Документ опирается на:
- [CLAUDE.md](../CLAUDE.md)
- [PETS_JSON_MAPPING_AUDIT.md](./PETS_JSON_MAPPING_AUDIT.md)
- текущий `scoring v2` и questionnaire contract

## Decision

`Freeads` принимается как:
- `primary reviewed source` для dog breed ingestion
- хороший источник для factual breed data
- хороший источник для structured trait draft
- недостаточный источник для полной engine truth без review

`Freeads` не используется как:
- runtime dependency
- auto-truth для scoring-sensitive полей
- единственный источник для `PetWise` breed quality

## Why This Source Is Useful

У breed pages `Freeads` есть достаточно стабильный structured layer:
- `Lifespan`
- `Breed group`
- `Weight`
- `Height`
- `Pedigree`
- `Other names`
- `Breed Size`
- `Breed Type`
- `Health tests available`
- `Characteristics`

А внутри `Characteristics` есть признаки, близкие к нашему engine:
- `Exercise needs`
- `Easy to train`
- `Shedding`
- `Grooming needs`
- `Good with Children`
- `Health of breed`
- `Cost to keep`
- `Intelligence`
- `Tolerates being alone`

## Source Limitations

`Freeads` не покрывает надёжно или явно:
- `apartmentSuitability`
- `goodWithOtherPets`
- `beginnerFriendly`
- `noiseLevel`
- `temperamentCalm`

Также у отдельных breed pages возможны taxonomy/meta ошибки, поэтому:
- `Breed group`
- `Breed type`
- и похожие классификационные поля

нельзя считать абсолютной истиной без review.

## Mapping Tiers

### A. Auto-import

Эти поля можно переносить автоматически в candidate snapshot:

| Freeads field | PetWise field | Rule |
|---|---|---|
| page title / breed name | `name` | после slug/manifest normalization |
| `Other names` | `aliases` | split + trim |
| `Breed group` | `groupDraft` | пока только draft metadata |
| `Breed Size` | `attributeExtractionHints.sizeDraft` | через rubric |
| `Lifespan` | `sourceFacts.lifespan` | raw factual field |
| `Weight` | `sourceFacts.weight` | raw factual field |
| `Height` | `sourceFacts.height` | raw factual field |
| `Health tests available` | `quality.sourceNotes` / `sourceFacts.healthTestsAvailable` | raw note |
| intro/summary text | `contentDraft.summaryShort` | after rewrite/trimming |
| hero image | `mediaDraft.imageUrl` | если стабильно доступен |

### B. Draft-only

Эти поля можно нормализовать в candidate hints, но не писать сразу в canonical
`attributes`:

| Freeads field | PetWise field | Why draft-only |
|---|---|---|
| `Exercise needs` | `exerciseNeeds` | структурно близко, но нужен rubric |
| `Easy to train` | `trainability` | нужен numeric normalization |
| `Shedding` | `sheddingLevel` | нужен numeric normalization |
| `Grooming needs` | `groomingNeeds` | нужен numeric normalization |
| `Good with Children` | `goodWithChildren` | чувствительно для trust |
| `Cost to keep` | `maintenanceCost` | coarse trait, не абсолют |
| `Tolerates being alone` | `aloneTolerance` | интерпретация не всегда однозначна |
| `Intelligence` | `intelligenceDraft` | useful hint, но не canonical field |
| `Health of breed` | `healthComplexityDraft` | future field, not current core |

### C. Review-required

Эти поля должны дозаполняться или валидироваться отдельно:

| PetWise field | Why review is required |
|---|---|
| `apartmentSuitability` | нет прямого stable поля в `Freeads` |
| `goodWithOtherPets` | слабо или нерегулярно выражено |
| `beginnerFriendly` | требует composite judgment |
| `noiseLevel` | редко выражено явно |
| `temperamentCalm` | чаще implied, чем stated |
| `flags.*` | не должны рождаться из одного prose source автоматически |

### D. Missing

Для текущего engine `Freeads` не даёт полного stable equivalent для:
- `goodWithOtherPets`
- `noiseLevel`
- `temperamentCalm`

Эти поля должны добираться через:
- review
- второй источник
- отдельный breed rubric

## Normalization Rubric

### `Breed Size` -> `size` draft

| Freeads | PetWise draft |
|---|---|
| `Toy` | `1` |
| `Small` | `2` |
| `Medium` | `3` |
| `Large` | `4` |
| `Giant` | `5` |

### `Exercise needs` -> `exerciseNeeds` draft

| Freeads | PetWise draft |
|---|---|
| `Low` | `2` |
| `Medium` | `3` |
| `High` | `5` |

### `Easy to train` -> `trainability` draft

| Freeads | PetWise draft |
|---|---|
| `Hard` | `2` |
| `Medium` | `3` |
| `High` | `5` |

### `Shedding` -> `sheddingLevel` draft

| Freeads | PetWise draft |
|---|---|
| `Very light` | `1` |
| `Light` | `2` |
| `Medium` | `3` |
| `High` | `5` |

### `Grooming needs` -> `groomingNeeds` draft

| Freeads | PetWise draft |
|---|---|
| `Low` | `2` |
| `Medium` | `3` |
| `High` | `5` |

### `Good with Children` -> `goodWithChildren` draft

| Freeads | PetWise draft |
|---|---|
| `Unsuited to children` | `1` |
| `Requires supervision` | `2` |
| `Suited to older children` | `3` |
| `Good with children` | `4` |
| `Excellent family dog` | `5` |

### `Cost to keep` -> `maintenanceCost` draft

| Freeads | PetWise draft |
|---|---|
| `Low` | `2` |
| `Medium` | `3` |
| `High` | `5` |

### `Tolerates being alone` -> `aloneTolerance` draft

| Freeads | PetWise draft |
|---|---|
| `Low anxiety` | `4` |
| `Medium` | `3` |
| `High anxiety` | `1` |

Важно:
- это только `draft`
- reviewer должен смотреть, не скрывает ли label более тонкий context

## Candidate Schema Expectations

`Freeads` importer должен генерировать не `breed.*.json`, а `candidate.*.json`
со следующими группами:
- `source`
- `sourceFacts`
- `mediaDraft`
- `contentDraft`
- `attributeExtractionHints`
- `importStatus`
- `quality`

Правила:
- `attributesReady = false`
- `flagsReady = false`
- `needsReview = true`

## Review Checklist

Перед переводом `Freeads` candidate в canonical breed fixture:

1. Проверить identity:
- `breedId`
- `name`
- `aliases`
- `slug`
- `sourceUrl`

2. Проверить content:
- `summaryShort` короткий и полезный
- `strengths` не дублируются
- `watchouts` практичны, а не декоративны

3. Проверить scoring-sensitive draft:
- `exerciseNeeds`
- `trainability`
- `sheddingLevel`
- `groomingNeeds`
- `goodWithChildren`
- `maintenanceCost`
- `aloneTolerance`

4. Дозаполнить missing `PetWise` fields:
- `apartmentSuitability`
- `goodWithOtherPets`
- `beginnerFriendly`
- `noiseLevel`
- `temperamentCalm`

## Recommended Pipeline

1. Собрать index manifest из `https://www.freeads.co.uk/dog-breeds`
2. Для нужных пород сохранить raw snapshot breed page
3. Сгенерировать `candidate.*.json`
4. Пройти review
5. Только после этого собирать final `breed.*.json`

## Non-goals

Пока не делаем:
- auto-import всех breed pages напрямую в canonical catalog
- runtime scraping
- автоматическое обновление уже релизнутых breed fixtures без review
