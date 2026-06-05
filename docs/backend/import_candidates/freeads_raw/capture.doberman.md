# Capture Notes: Doberman

## Current state

- breed URL: `https://www.freeads.co.uk/dog-breeds/dobermann`
- status: `needs_browser_capture`

Что уже подтверждено:
- slug и breed URL существуют в Freeads breed index
- direct fetch специально пропущен, потому что remaining breed pages уже
  устойчиво попадают в Cloudflare/browser-capture lane
- search выдача уводит в classifieds, а не в breed facts

## What to capture next

Нужный minimum useful snapshot:
- intro summary
- `Breed Size`
- `Exercise needs`
- `Easy to train`
- `Good with Children`
- `Cost to keep`
- `Tolerates being alone`

## Why this breed is important

- важна для demanding working-dog branch
- влияет на trust у пользователей, когда match касается крупных и сложных пород
- уже есть canonical breed, но `Freeads` review layer для неё пока пуст

## Exit condition

Capture считается достаточным, если удаётся получить:
- summary
- минимум `3` structured trait labels

Тогда породу можно повторно прогнать через:
- `generate_freeads_candidates.py`
- `generate_freeads_review_pack.py`
