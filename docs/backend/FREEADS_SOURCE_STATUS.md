# Freeads Source Status

Этот файл отслеживает реальное состояние `Freeads` как ingestion source по
каждой породе из pilot batch.

Статусы:
- `search_snippet_complete` — есть достаточно данных для raw snapshot и
  candidate generation
- `index_verified_only` — breed page URL подтверждён по A-Z index, но
  structured facts пока не сняты
- `needs_browser_capture` — для качественного raw snapshot нужен
  browser-assisted capture

## Pilot batch status

| breedId | Freeads page | Status | Notes |
|---|---|---|---|
| `maltese` | `/dog-breeds/maltese` | `search_snippet_complete` | есть summary + trait block |
| `pug` | `/dog-breeds/pug` | `search_snippet_complete` | есть summary + facts + trait block |
| `english_cocker_spaniel` | `/dog-breeds/cocker-spaniel` | `search_snippet_complete` | есть summary + aliases + health tests + trait block |
| `yorkshire_terrier` | `/dog-breeds/yorkshire-terrier` | `index_verified_only` | URL подтверждён через A-Z index |
| `jack_russell_terrier` | `/dog-breeds/jack-russell` | `index_verified_only` | URL подтверждён через A-Z index |
| `american_cocker_spaniel` | `/dog-breeds/american-cocker-spaniel` | `index_verified_only` | URL подтверждён через A-Z index |
| `rottweiler` | `/dog-breeds/rottweiler` | `index_verified_only` | URL подтверждён через A-Z index |
| `doberman` | `/dog-breeds/dobermann` | `index_verified_only` | URL подтверждён через A-Z index |

## Implication

Сейчас можно безопасно делать:
- pilot candidate generation для первых `3` пород
- rubric tuning на реальных `Freeads` labels
- comparison с текущими canonical fixtures

Следующий шаг для полного pilot batch:
- browser-assisted capture ещё `5` пород

## Why this matters

Это удерживает pipeline честным:
- мы не притворяемся, что у нас уже есть полные raw snapshots по всем `8`
- но и не блокируем работу там, где `Freeads` уже дал достаточно signal
