# Capture Notes: American Cocker Spaniel

## Current state

- breed URL: `https://www.freeads.co.uk/dog-breeds/american-cocker-spaniel`
- status: `needs_browser_capture`

Что уже подтверждено:
- slug и breed URL существуют
- direct `curl` fetch сейчас возвращает Cloudflare challenge page
- обычный search snippet подменяется classified listing pages, а не breed details

## What to capture next

Нужный minimum useful snapshot:
- intro summary
- `Breed Size`
- `Exercise needs`
- `Easy to train`
- `Grooming needs`
- `Good with Children`
- `Cost to keep`
- `Tolerates being alone`

## Why this breed is important

- помогает лучше развести `english_cocker_spaniel` vs `american_cocker_spaniel`
- улучшает family / active companion branch
- сейчас canonical breed уже есть, но Freeads review layer для него почти пуст

## Exit condition

Capture считается достаточным, если удаётся получить:
- summary
- минимум `3` structured trait labels

Тогда породу можно повторно прогнать через:
- `generate_freeads_candidates.py`
- `generate_freeads_review_pack.py`
