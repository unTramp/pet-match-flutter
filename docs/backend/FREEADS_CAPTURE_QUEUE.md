# Freeads Capture Queue

Этот документ фиксирует следующий practical backlog после первого reviewed
pass.

Сейчас `Freeads` pilot batch делится так:
- `3` породы уже имеют snippet-level structured signal
- `5` пород пока остаются `index_verified_only`

Задача этой очереди:
- сфокусировать следующий цикл на тех породах, где capture даст максимальную
  продуктовую пользу
- не тратить время на бессистемный backfill

## Queue

### 1. `american_cocker_spaniel`

Почему высокий приоритет:
- уже есть canonical breed в каталоге
- близка к `english_cocker_spaniel`, поэтому хороший capture поможет лучше
  развести spaniel-ветку
- потенциально важна для family / active companion сегмента

Что особенно нужно из `Freeads`:
- `Breed Size`
- `Exercise needs`
- `Easy to train`
- `Grooming needs`
- `Good with Children`
- `Cost to keep`
- `Tolerates being alone`
- summary intro

Ожидаемая польза:
- лучшее разведение `english_cocker_spaniel` vs `american_cocker_spaniel`
- более точный result/details контент

Текущее ограничение:
- breed URL существует, но direct fetch сейчас режется Cloudflare challenge
- см. [capture.american_cocker_spaniel.md](./import_candidates/freeads_raw/capture.american_cocker_spaniel.md)

### 2. `rottweiler`

Почему высокий приоритет:
- крупная и поведенчески значимая порода
- влияет на guardian / large-house сценарии
- сейчас review pack полностью упирается в отсутствие structured source signal

Что особенно нужно из `Freeads`:
- `Breed Size`
- `Exercise needs`
- `Easy to train`
- `Good with Children`
- `Cost to keep`
- `Tolerates being alone`
- intro summary

Ожидаемая польза:
- лучшее подтверждение large-guardian profile
- больше доверия к ranking/result для крупных рабочих пород

Текущее ограничение:
- breed URL существует, но direct fetch сейчас режется Cloudflare challenge
- см. [capture.rottweiler.md](./import_candidates/freeads_raw/capture.rottweiler.md)

### 3. `jack_russell_terrier`

Почему высокий приоритет:
- терьер с ярким activity profile
- важен для “маленький, но очень активный” сценария

Что особенно нужно из `Freeads`:
- `Exercise needs`
- `Easy to train`
- `Good with Children`
- `Tolerates being alone`
- intro summary

Ожидаемая польза:
- лучшее отличие от `maltese`, `pug`, `yorkshire_terrier`
- сильнее покроет active-small-dog branch

Текущее ограничение:
- breed URL существует, но direct fetch сейчас режется Cloudflare challenge
- см. [capture.jack_russell_terrier.md](./import_candidates/freeads_raw/capture.jack_russell_terrier.md)

### 4. `yorkshire_terrier`

Почему средний приоритет:
- уже довольно понятный toy-companion profile
- но полезно подтвердить grooming / vocal / apartment semantics

Что особенно нужно из `Freeads`:
- `Breed Size`
- `Shedding`
- `Grooming needs`
- `Good with Children`
- `Cost to keep`
- intro summary

Ожидаемая польза:
- лучшее отличие от `maltese`
- более честный grooming-heavy content

Текущее ограничение:
- breed URL существует, но direct fetch сейчас режется Cloudflare challenge
- см. [capture.yorkshire_terrier.md](./import_candidates/freeads_raw/capture.yorkshire_terrier.md)

### 5. `doberman`

Почему средний приоритет:
- product value высокий, но breed уже и так стоит в “сложной/требовательной”
  части каталога
- без richer source capture пока лучше не двигать его aggressively

Что особенно нужно из `Freeads`:
- `Breed Size`
- `Exercise needs`
- `Easy to train`
- `Good with Children`
- `Cost to keep`
- `Tolerates being alone`
- intro summary

Ожидаемая польза:
- лучшее подтверждение demanding working-dog profile
- более сильный provenance слой для breed detail

Текущее ограничение:
- для remaining Freeads breed pages direct fetch больше не проверяется
  поштучно и считается частью browser-capture lane
- см. [capture.doberman.md](./import_candidates/freeads_raw/capture.doberman.md)

## Recommended order

1. `american_cocker_spaniel`
2. `rottweiler`
3. `jack_russell_terrier`
4. `yorkshire_terrier`
5. `doberman`

## Capture rule

Следующий цикл считается успешным, если для каждой породы получается хотя бы:
- `summary`
- `3+` structured trait labels

Тогда порода может перейти из `index_verified_only` в usable review state.
