# Capture Notes: Jack Russell Terrier

## Current state

- breed URL: `https://www.freeads.co.uk/dog-breeds/jack-russell`
- status: `needs_browser_capture`

Что уже подтверждено:
- slug и breed URL существуют
- direct `curl` fetch сейчас возвращает Cloudflare challenge page
- search выдача уводит в classifieds, а не в breed facts

## What to capture next

Нужный minimum useful snapshot:
- intro summary
- `Breed Size`
- `Exercise needs`
- `Easy to train`
- `Good with Children`
- `Tolerates being alone`

## Why this breed is important

- важна для active-small-dog branch
- помогает лучше отличать терьерный профиль от `maltese`, `pug`,
  `yorkshire_terrier`
- уже есть canonical breed, но `Freeads` review layer для него пока пуст

## Exit condition

Capture считается достаточным, если удаётся получить:
- summary
- минимум `3` structured trait labels

Тогда породу можно повторно прогнать через:
- `generate_freeads_candidates.py`
- `generate_freeads_review_pack.py`
