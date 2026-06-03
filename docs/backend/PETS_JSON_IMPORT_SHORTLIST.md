# pets_json Import Shortlist

Этот файл фиксирует **первый практический пакет импорта** из
`/Users/andreydorofeev/Development/CLAUDE/pet_match_parser/pets_json`
в каталог `PetWise`.

Документ опирается на:
- текущий `catalog.v1`
- [PETS_JSON_MAPPING_AUDIT.md](./PETS_JSON_MAPPING_AUDIT.md)
- product-first и ROI правила из [docs/CLAUDE.md](../CLAUDE.md)

## Goal

Не “импортировать всё”, а взять такой набор пород, который:
- расширяет пользовательские сценарии
- не плодит дубликаты
- даёт быстрый value через media + content
- не ломает scoring из-за сырого auto-mapping

## Current Catalog Coverage

Уже есть в `PetWise`:
- `whippet`
- `cavalier_king_charles_spaniel`
- `italian_greyhound`
- `basenji`
- `border_collie`
- `french_bulldog`
- `labrador_retriever`
- `miniature_poodle`
- `shih_tzu`
- `golden_retriever`
- `german_shepherd`
- `dachshund`
- `beagle`
- `bichon_frise`
- `australian_shepherd`
- `siberian_husky`
- `boxer`
- `chihuahua`

Поэтому первый новый пакет должен избегать этих breed entities
и добавлять действительно новые сегменты.

## First Import Package

### Recommended new breeds

| Priority | pets_json `breed_code` | PetWise `breedId` | Display name | Mode | Why now |
|---|---|---|---|---|---|
| 1 | `maltese` | `maltese` | Maltese | `new breed` | strong apartment / calm companion segment |
| 2 | `pug` | `pug` | Pug | `new breed` | mass-market small apartment breed |
| 3 | `yorkshire-terrier` | `yorkshire_terrier` | Yorkshire Terrier | `new breed` | toy-size, grooming-heavy, compact scenario |
| 4 | `jack-russell-terrier` | `jack_russell_terrier` | Jack Russell Terrier | `new breed` | active compact breed, good contrast to calm small dogs |
| 5 | `spaniel-cocker` | `english_cocker_spaniel` | English Cocker Spaniel | `new breed` | family spaniel segment with richer grooming profile |
| 6 | `spaniel-american-cocker` | `american_cocker_spaniel` | American Cocker Spaniel | `new breed` | more decorative spaniel branch, useful contrast |
| 7 | `rottweiler` | `rottweiler` | Rottweiler | `new breed` | large guardian / house scenario |
| 8 | `dobermann` | `doberman` | Doberman | `new breed` | active large guardian / trainable scenario |

### Variant-only backlog

Эти записи есть в `pets_json`, но их пока не стоит заводить как отдельные
breed entities в первом пакете:

| pets_json `breed_code` | Suggested handling | Reason |
|---|---|---|
| `chihuahua-smooth-coat` | variant / alias | у нас уже есть `chihuahua` |
| `chihuahua-long-coat` | variant / alias | не нужен как отдельный breed record сейчас |
| `dachshund-miniature-long-haired` | variant backlog | сначала базовая `dachshund` entity |
| `dachshund-miniature-smooth-haired` | variant backlog | слишком ранняя детализация |
| `dachshund-miniature-wire-haired` | variant backlog | слишком ранняя детализация |
| `dachshund-long-haired` | variant backlog | лучше как subtype later |
| `dachshund-smooth-haired` | variant backlog | лучше как subtype later |
| `dachshund-wire-haired` | variant backlog | лучше как subtype later |
| `poodle-standard` | variant backlog | сначала не распыляться после `miniature_poodle` |
| `poodle-toy` | variant backlog | high overlap with current small companion pool |

## Import Mode Per Breed

### What to import immediately

Для каждой породы из первого пакета можно брать сразу:
- `breed_code` -> `breedId`
- `breed_name` -> `name`
- `pet_type` -> `petType`
- `image_url` -> `imageUrl`
- `gallery_images` -> `galleryImages`
- `sections.peculiarities` -> raw source for `summaryShort`
- `sections.requirements` -> raw source for `watchouts`
- `sections.suitable_for` -> raw source for `strengths`
- `sections.expenses` -> raw source for `maintenanceCost` review

### What must stay review-only

Не импортировать автоматически в scoring:
- `size`
- `apartmentSuitability`
- `exerciseNeeds`
- `aloneTolerance`
- `goodWithChildren`
- `goodWithOtherPets`
- `groomingNeeds`
- `sheddingLevel`
- `beginnerFriendly`
- `maintenanceCost`
- `noiseLevel`
- `trainability`
- `temperamentCalm`
- all `flags`

## Suggested Processing Order

### Batch A — quickest ROI

1. `maltese`
2. `pug`
3. `yorkshire_terrier`
4. `jack_russell_terrier`

Почему:
- сильно расширяют small/apartment coverage
- добавляют контраст calm vs active small breeds
- помогают `Result` и `Details` уже на первом шаге

### Batch B — family and grooming contrast

5. `english_cocker_spaniel`
6. `american_cocker_spaniel`

Почему:
- дают новый “семейный спаниель” сегмент
- усиливают сценарии про уход и умеренную/высокую активность

### Batch C — large guardian branch

7. `rottweiler`
8. `doberman`

Почему:
- усиливают large/house scenarios
- дают engine более широкий high-discipline / strong-owner branch

## Candidate Notes

### `maltese`
- strong fit for calm apartment companion segment
- likely high grooming contrast
- useful for small-dog result scenarios

### `pug`
- strong mainstream apartment breed
- useful for low-space / lower-activity personas
- may need later health-complexity handling, but not blocking for content import

### `yorkshire_terrier`
- compact but not identical to `maltese`
- useful for grooming-heavy and toy-size scenarios

### `jack_russell_terrier`
- very important contrast breed
- prevents small-dog pool from becoming too “soft/calm”

### `english_cocker_spaniel`
- family-friendly, moderate, grooming-relevant
- strong content value for details

### `american_cocker_spaniel`
- similar family branch but visually/content-wise distinct enough
- should not block import if we want more compact first batch

### `rottweiler`
- important for large house/guardian branch
- helps ranking scenarios where user clearly wants space + structure

### `doberman`
- important for active/trainable/guardian contrast
- good complement to `german_shepherd`

## If We Need a Smaller First Batch

Если хотим не 8, а 5 пород, лучший набор:
- `maltese`
- `pug`
- `yorkshire_terrier`
- `jack_russell_terrier`
- `english_cocker_spaniel`
- `american_cocker_spaniel`
- `rottweiler`
- `doberman`

Это даёт лучший баланс:
- small calm
- small active
- family moderate
- large active
- mainstream apartment

## Recommended Next Step

Практически следующий шаг такой:
1. Для этих 8 пород собрать raw source snapshot из `pets_json`
2. Создать draft fixtures с:
   - `breedId`
   - `petType`
   - `name`
   - `imageUrl`
   - `content.summaryShort`
   - `content.strengths`
   - `content.watchouts`
   - `quality.needsReview = true`
3. Scoring attributes дозаполнять отдельно по rubric
