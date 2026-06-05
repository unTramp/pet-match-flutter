# Freeads Review Pack

Эта папка хранит **review artifacts**, которые сравнивают:
- текущий canonical `breed.*.json`
- и `Freeads`-candidate для той же породы

Это не runtime данные и не финальные import fixtures.

## Что здесь лежит

- `review.<breedId>.json` — сравнение по одной породе
- `summary.v1.json` — агрегированная сводка по pilot batch

## Что сравнивается

Автоматически сравниваемые поля:
- `size`
- `exerciseNeeds`
- `aloneTolerance`
- `goodWithChildren`
- `groomingNeeds`
- `sheddingLevel`
- `maintenanceCost`
- `trainability`

Поля, которые `Freeads` не покрывает надёжно и потому всегда идут как
`review_required_not_in_source`:
- `apartmentSuitability`
- `goodWithOtherPets`
- `beginnerFriendly`
- `noiseLevel`
- `temperamentCalm`

## Status values

- `match`
- `near_match`
- `drift`
- `missing_from_source`
- `review_required_not_in_source`

## Генерация

```bash
python3 tool/backend_specs/generate_freeads_review_pack.py
```

## Практический смысл

Review pack нужен, чтобы:
1. не обновлять canonical catalog “на глаз”
2. видеть, где `Freeads` уже помогает
3. быстро находить поля, где есть drift или просто не хватает source coverage
