# Freeads Source Status

Этот файл отслеживает реальное состояние `Freeads` как ingestion source по
каждой породе из pilot batch.

Статусы:
- `verified_via_browser_capture` — breed page открыта в браузере, HTML сохранён
  и распарсен в raw snapshot
- `needs_browser_capture` — для качественного raw snapshot всё ещё нужен
  browser-assisted capture

## Pilot batch status

| breedId | Freeads page | Status | Notes |
|---|---|---|---|
| `maltese` | `/dog-breeds/maltese` | `verified_via_browser_capture` | HTML сохранён, raw/candidate/review обновлены |
| `pug` | `/dog-breeds/pug` | `verified_via_browser_capture` | HTML сохранён, raw/candidate/review обновлены |
| `english_cocker_spaniel` | `/dog-breeds/cocker-spaniel` | `verified_via_browser_capture` | HTML сохранён, raw/candidate/review обновлены |
| `yorkshire_terrier` | `/dog-breeds/yorkshire-terrier` | `verified_via_browser_capture` | HTML сохранён, raw/candidate/review обновлены |
| `jack_russell_terrier` | `/dog-breeds/jack-russell` | `verified_via_browser_capture` | HTML сохранён, raw/candidate/review обновлены |
| `american_cocker_spaniel` | `/dog-breeds/american-cocker-spaniel` | `verified_via_browser_capture` | HTML сохранён, raw/candidate/review обновлены |
| `rottweiler` | `/dog-breeds/rottweiler` | `verified_via_browser_capture` | HTML получен и уже даёт полноценный structured trait signal |
| `doberman` | `/dog-breeds/dobermann` | `verified_via_browser_capture` | HTML сохранён, raw/candidate/review обновлены |

## Implication

Сейчас можно безопасно делать:
- reviewed passes уже по всем `8` породам
- rubric tuning на реальных Freeads labels
- comparison с canonical fixtures по всему pilot batch

## Why this matters

Это удерживает pipeline честным:
- весь pilot batch теперь живёт на одном и том же классе source quality
- provenance уже понятен по всему pilot batch
- reviewer может принимать решения на одном и том же классе source quality
