# pets_json Mapping Audit

Этот документ фиксирует, как использовать данные из
`/Users/andreydorofeev/Development/CLAUDE/pet_match_parser/pets_json`
для расширения каталога `PetWise`.

Цель:
- быстро расширять breed catalog
- не ломать deterministic scoring
- использовать внешний источник как `content/enrichment layer`, а не как
  прямую истину для engine

## Short Conclusion

`pets_json` хорошо подходит для:
- `breed identity`
- `imageUrl`
- `galleryImages`
- `summary/content` для `Result` и `Details`
- текстовых `strengths/watchouts/adaptationTips`

`pets_json` плохо подходит как прямой источник для:
- `apartmentSuitability`
- `aloneTolerance`
- `goodWithChildren`
- `goodWithOtherPets`
- `beginnerFriendly`
- `noiseLevel`
- `trainability`
- `temperamentCalm`

Эти поля должны оставаться в нашем каноническом каталоге и проходить
отдельную нормализацию/review.

## Source Snapshot

Что сейчас видно по источнику:
- файлов: `424`
- `pet_type=собаку`: `322`
- `pet_type=кошку`: `102`
- у всех файлов есть:
  - `breed_id`
  - `breed_code`
  - `breed_name`
  - `pet_type`
  - `summary`
  - `image_url`
  - `gallery_url`
  - `gallery_images`
  - `sections`
- у всех файлов `sections` состоит из 4 блоков:
  - `peculiarities`
  - `requirements`
  - `expenses`
  - `suitable_for`

Качество данных:
- `summary` почти везде пустой или бесполезный
- `image_url` и `gallery_images` заполнены стабильно
- секции имеют хороший потенциал для enrichment

## Current PetWise Breed Shape

Сейчас канонический breed fixture в `PetWise` содержит:
- `breedId`
- `petType`
- `name`
- `aliases`
- `group`
- `attributes`
- `flags`
- `content`
- `quality`
- `imageUrl`

Пример:
- [breed.whippet.json](./examples/breed.whippet.json)

## Mapping Policy

### A. Direct Mapping

Эти поля можно переносить почти напрямую:

| pets_json | PetWise | Правило |
|---|---|---|
| `breed_code` | `breedId` | нормализовать в snake_case / canonical id |
| `pet_type` | `petType` | `собаку -> dog`, `кошку -> cat` |
| `breed_name` | `name` | брать как display name после текстовой проверки |
| `image_url` | `imageUrl` | переносить напрямую |
| `gallery_images` | `content.galleryImages` или future field | можно хранить отдельно для details/gallery |
| `gallery_url` | `quality.sourceNotes` | как source reference при желании |

### B. Safe Derived Content

Эти поля можно собирать из секций, но с review:

| Source | PetWise | Как извлекать |
|---|---|---|
| `sections.peculiarities.body` | `content.summaryShort` | вручную или AI rewrite в короткий 1-line summary |
| `sections.suitable_for.body` | `content.strengths` | выделять 2–4 сильные стороны |
| `sections.requirements.body` | `content.watchouts` | выделять 2–3 практических нюанса |
| `sections.requirements.body` | `content.adaptationTips` | превращать в actionable tips |
| `sections.expenses.body` | `quality.sourceNotes` | оставлять как raw source clue |

### C. Review Queue Only

Эти поля нельзя переносить в scoring без отдельной оценки:

| PetWise field | Почему нельзя напрямую |
|---|---|
| `size` | в `pets_json` нет надёжного numeric field |
| `apartmentSuitability` | иногда выражено текстом, но нерегулярно |
| `exerciseNeeds` | можно оценивать по тексту, но нужен parser/rubric |
| `aloneTolerance` | почти нигде не выражено явно |
| `goodWithChildren` | слабое покрытие |
| `goodWithOtherPets` | слабое покрытие и много двусмысленности |
| `groomingNeeds` | частично извлекаемо из `requirements`, но требует нормализации |
| `sheddingLevel` | выражено не всегда |
| `beginnerFriendly` | чаще implied, чем stated |
| `maintenanceCost` | можно приблизительно вывести из `expenses`, но нужен rubric |
| `noiseLevel` | редко и неструктурно |
| `trainability` | редко и неструктурно |
| `temperamentCalm` | иногда implied, но ненадёжно |
| `flags.*` | почти все требуют отдельной валидации |

### D. Ignore

Пока не стоит использовать:
- `summary` как source of truth
- любые неформализованные куски текста как прямые numeric attributes
- автоматически сгенерированные оценки без review

## Recommended Field Mapping

### Minimal import for fast catalog expansion

Если хотим быстро получить value без риска для engine:

Обязательно импортировать:
- `breedId`
- `petType`
- `name`
- `imageUrl`
- `galleryImages`
- `content.summaryShort`
- `content.strengths`
- `content.watchouts`
- `quality.sourceNotes`

Не менять автоматически:
- `attributes`
- `flags`
- `quality.confidenceScore`

### Enrichment-only mode

Лучший первый режим использования `pets_json`:
- сохранить текущие scoring attributes как есть
- брать из `pets_json` только identity/content/media
- потом отдельно дообогащать attributes через rubric или AI-assisted review

## Suggested Extraction Rules

### `petType`

```txt
собаку -> dog
кошку -> cat
```

### `breedId`

Предпочтительно:
1. брать `breed_code`
2. нормализовать:
   - lowercase
   - spaces -> `_`
   - remove punctuation
3. если уже есть canonical breedId в `PetWise`, использовать именно его

### `summaryShort`

Правило:
- не брать raw `summary`
- строить из `peculiarities + suitable_for`
- максимум 1 короткое предложение
- без цен, без длинных пояснений

Пример good output:
- `Активная и умная порода, лучше чувствует себя у вовлеченного владельца с пространством для движения.`

### `strengths`

Брать только пользовательски значимые плюсы:
- `подходит для квартиры`
- `подходит для активного образа жизни`
- `простой уход`
- `дружелюбна к семье`
- `хороший вариант для спокойного домашнего ритма`

Избегать:
- повторов из summary
- слишком общих фраз без пользы

### `watchouts`

Хорошие watchouts:
- `нуждается в регулярной активности`
- `требует частого ухода за шерстью`
- `лучше чувствует себя в доме с пространством`
- `может быть не лучшим выбором для совсем новичка`

Избегать:
- длинных объяснений
- медицинских утверждений без валидации

### `galleryImages`

Если будем расширять schema:
- хранить отдельно от `imageUrl`
- `imageUrl` использовать как hero
- `galleryImages` использовать в Details/Gallery

## Audit Checklist Per Breed

Перед импортом каждой породы пройти 3 блока:

### 1. Identity check
- `breed_code` выглядит канонично
- `breed_name` нормальный и без мусора
- `pet_type` правильно маппится
- hero image открывается
- `gallery_images` не пустой

### 2. Content check
- `summaryShort` читается по-человечески
- `strengths` не дублируют друг друга
- `watchouts` полезны пользователю
- нет мусорных фраз вроде `tst`
- нет сломанной локализации

### 3. Scoring safety check
- никакие numeric `attributes` не перезаписаны blindly
- если поле выводится из текста, оно помечено `needsReview=true`
- спорные выводы уходят в review queue

## Review Queue Format

Рекомендую для полуавтоматического импорта такую пометку:

```json
{
  "quality": {
    "confidenceScore": 0.55,
    "sourceCount": 1,
    "sourceNotes": [
      "pets_json import: requirements + suitable_for"
    ],
    "needsReview": true,
    "version": 1
  }
}
```

Идея:
- content можно импортировать быстрее
- scoring-sensitive поля не считаются готовыми без review

## Best ROI Plan

### Phase 1
- взять `10–20` dog breeds из `pets_json`
- импортировать:
  - `name`
  - `petType`
  - `imageUrl`
  - `galleryImages`
  - `content.summaryShort`
  - `content.strengths`
  - `content.watchouts`

### Phase 2
- вручную или AI-assisted заполнить missing scoring attributes
- отмечать спорные записи `needsReview=true`

### Phase 3
- подключить cats как отдельный поток
- не смешивать dog/cat scoring semantics заранее

## Recommended Decision

Использовать `pets_json` как:
- `content source`
- `media source`
- `identity source`

Не использовать `pets_json` как:
- прямой `scoring source`
- единственный источник truth для breed attributes

Если коротко:
- для `Result/Details` — да, очень полезно
- для `engine` — только через нормализацию и review
