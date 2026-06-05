# Freeads Capture Queue

Этот документ фиксирует следующий practical backlog после browser-capture pass
по всему pilot batch.

Сейчас `Freeads` pilot batch делится так:
- `8` пород уже имеют `verified_via_browser_capture`

## Capture status

Capture phase для pilot batch закрыта.

## Next review queue

Следующим циклом уже имеет смысл идти не в capture, а в review:

1. `rottweiler`
2. `american_cocker_spaniel`
3. `yorkshire_terrier`
4. `jack_russell_terrier`
5. `doberman`

Почему именно так:
- `rottweiler` и `american_cocker_spaniel` сейчас дают наиболее сильный новый
  signal для канонического каталога
- `yorkshire_terrier` и `jack_russell_terrier` больше полезны как точная
  дифференциация small-dog ветки, чем как срочный engine fix
- `doberman` уже captured, но reviewed pass по нему разумно делать после
  `rottweiler`, чтобы сначала закрепить более важную large-working ветку
