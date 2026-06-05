# Freeads Raw Snapshots

Эта папка предназначена для **сырых breed snapshots** из `Freeads`.

Файлы отсюда нужны только для offline ingestion pipeline и review.

Для ручного/браузерного сбора см.:
- [../../FREEADS_BROWSER_CAPTURE_PROTOCOL.md](../../FREEADS_BROWSER_CAPTURE_PROTOCOL.md)
- [freeads.template.json](./freeads.template.json)

Для полуавтоматического browser-assisted сбора и парсинга:

```bash
python3 tool/backend_specs/capture_freeads_html.py --breed-id rottweiler
python3 tool/backend_specs/parse_freeads_html.py --breed-id rottweiler
```

## Naming

Рекомендуемый формат:

```txt
freeads.<slug>.json
```

Примеры:
- `freeads.maltese.json`
- `freeads.rottweiler.json`
- `freeads.dobermann.json`

## Expected shape

```json
{
  "source": {
    "origin": "freeads",
    "url": "https://www.freeads.co.uk/dog-breeds/rottweiler",
    "scrapedAt": "2026-06-05",
    "urlStatus": "verified"
  },
  "identity": {
    "breedName": "Rottweiler",
    "slug": "rottweiler",
    "petType": "dog"
  },
  "summary": "Short intro text from the breed page",
  "heroImageUrl": "https://...",
  "facts": {
    "otherNames": [
      "Rottie"
    ],
    "breedGroup": "Working",
    "breedType": "Mastiff",
    "breedSize": "Large",
    "lifespan": "8-10 years",
    "weight": "36-61kg",
    "height": "56-69cm",
    "pedigree": "Yes",
    "healthTestsAvailable": "Hip score, eye tests"
  },
  "characteristics": {
    "exerciseNeeds": "High",
    "easyToTrain": "High",
    "shedding": "Medium",
    "groomingNeeds": "Low",
    "goodWithChildren": "Good with children",
    "healthOfBreed": "Average",
    "costToKeep": "High",
    "intelligence": "High",
    "toleratesBeingAlone": "Medium"
  },
  "quality": {
    "pageWarnings": []
  }
}
```

## Important rules

- не хранить здесь canonical `PetWise attributes`
- не дописывать reviewer conclusions в raw snapshot
- если URL был inferred, после ручной проверки менять `urlStatus` на `verified`
- учитывать, что direct `curl` по breed pages может получать Cloudflare challenge,
  поэтому source capture лучше делать browser-assisted способом
