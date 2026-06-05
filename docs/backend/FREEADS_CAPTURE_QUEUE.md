# Freeads Capture Queue

Этот документ фиксирует оставшийся practical backlog после browser-capture pass
по почти всему pilot batch.

Сейчас `Freeads` pilot batch делится так:
- `7` пород уже имеют `verified_via_browser_capture`
- `1` порода остаётся в `needs_browser_capture`

## Remaining capture queue

### 1. `doberman`

Почему остаётся первым:
- это последняя порода без полноценного browser-captured raw snapshot
- product value высокий: крупная рабочая порода с важным impact на demanding /
  guardian scenarios

Что особенно нужно из `Freeads`:
- `Breed Size`
- `Exercise needs`
- `Easy to train`
- `Good with Children`
- `Cost to keep`
- `Tolerates being alone`
- intro summary

Ожидаемая польза:
- полная консистентность pilot batch
- сильнее provenance для working-dog branch
- готовность к reviewed pass уже по всем `8` породам

Текущее ограничение:
- direct fetch больше не рассматривается как рабочий path
- нужен обычный browser-assisted capture по protocol
- см. [capture.doberman.md](./import_candidates/freeads_raw/capture.doberman.md)

## After capture backlog

После `doberman` следующим циклом уже имеет смысл делать не capture, а review:

1. `rottweiler`
2. `american_cocker_spaniel`
3. `yorkshire_terrier`
4. `jack_russell_terrier`

Почему именно так:
- `rottweiler` и `american_cocker_spaniel` сейчас дают наиболее сильный новый
  signal для канонического каталога
- `yorkshire_terrier` и `jack_russell_terrier` больше полезны как точная
  дифференциация small-dog ветки, чем как срочный engine fix

## Capture rule

Цикл считается завершённым, когда по последней породе есть:
- saved browser HTML
- parsed raw snapshot
- regenerated candidate
- regenerated review pack
