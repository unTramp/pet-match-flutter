# Capture Notes: Rottweiler

## Current state

- breed URL: `https://www.freeads.co.uk/dog-breeds/rottweiler`
- status: `needs_browser_capture`

Что уже подтверждено:
- slug и breed URL существуют
- direct `curl` fetch сейчас возвращает Cloudflare challenge page
- search выдача уводит в classified listing pages, а не в breed facts

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

- важна для guardian / large-house branch
- влияет на perception trust у крупных и требовательных пород
- сейчас canonical breed уже есть, но `Freeads` review layer для неё пуст

## Exit condition

Capture считается достаточным, если удаётся получить:
- summary
- минимум `3` structured trait labels

Тогда породу можно повторно прогнать через:
- `generate_freeads_candidates.py`
- `generate_freeads_review_pack.py`
