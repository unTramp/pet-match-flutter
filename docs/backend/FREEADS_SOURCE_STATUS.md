# Freeads Source Status

Этот файл отслеживает реальное состояние `Freeads` как ingestion source по
каждой породе из pilot batch.

Статусы:
- `verified_via_browser_capture` — breed page открыта в браузере, HTML сохранён
  и распарсен в raw snapshot
- `verified_via_search_snippet` — есть usable signal только через search snippet
- `needs_browser_capture` — для качественного raw snapshot нужен browser-assisted
  capture

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
| `doberman` | `/dog-breeds/dobermann` | `needs_browser_capture` | direct fetch не годится, remaining last pilot breed |

## Implication

Сейчас можно безопасно делать:
- reviewed passes уже по `7` породам
- rubric tuning на реальных Freeads labels
- comparison с canonical fixtures почти по всему pilot batch

Следующий шаг для полного pilot batch:
- browser-assisted capture `doberman`

## Why this matters

Это удерживает pipeline честным:
- мы больше не смешиваем snippet-level и browser-level source quality в одной
  таблице
- provenance уже понятен почти по всему pilot batch
- reviewer может принимать решения на одном и том же классе source quality
