# Freeads Capture Queue

Этот документ фиксирует следующий practical backlog после полного
browser-capture pass по pilot batch.

Сейчас `Freeads` pilot batch делится так:
- `8` пород уже имеют `verified_via_browser_capture`
- reviewed pass по ним завершён

## Capture status

Capture и review фаза для pilot batch закрыта.

## Next capture queue: Phase 2 breadth expansion

Следующим циклом имеет смысл идти в новый manifest, а не продолжать пилот:

1. `papillon`
2. `pomeranian`
3. `west_highland_white_terrier`
4. `miniature_schnauzer`
5. `boston_terrier`
6. `staffordshire_bull_terrier`
7. `akita`
8. `bernese_mountain_dog`

Почему именно так:
- `papillon` и `pomeranian` добавляют toy-companion branch, которого сейчас
  мало в catalog breadth
- `west_highland_white_terrier` и `miniature_schnauzer` дают small utility /
  lower-shedding contrast против уже импортированных companion breeds
- `boston_terrier` и `staffordshire_bull_terrier` расширяют compact
  bully/terrier сегмент без дублирования текущих пород
- `akita` и `bernese_mountain_dog` закрывают large spitz / gentle giant
  ветки, которых сейчас нет в каноническом каталоге

Практический вход:
- [import_candidates/freeads_phase2_manifest.v1.json](./import_candidates/freeads_phase2_manifest.v1.json)
- [FREEADS_BROWSER_CAPTURE_PROTOCOL.md](./FREEADS_BROWSER_CAPTURE_PROTOCOL.md)
