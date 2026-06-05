# Freeads Browser Capture Protocol

Этот документ описывает **медленный и безопасный** способ собирать данные с
`Freeads`, когда breed page недоступна для обычного `curl` из-за Cloudflare
challenge.

Цель:
- получить usable raw snapshot
- не притворяться, что автоматический fetch работает там, где он не работает
- снизить риск rate-limit / дополнительных блокировок

## Когда использовать этот путь

Используй browser-assisted capture, если одновременно верно хотя бы одно:
- search snippets не дают breed facts
- direct `curl` отдаёт challenge page
- raw snapshot сейчас в статусе `needs_browser_capture`

Сейчас это уже относится к:
- `american_cocker_spaniel`
- `rottweiler`
- `jack_russell_terrier`

## Safe operating rules

Чтобы не дёргать сайт агрессивно:
- обрабатывать не больше `1` породы за раз
- между породами делать паузу минимум `60–120` секунд
- не перезагружать одну и ту же breed page много раз подряд
- не открывать сразу пачку вкладок на один домен
- после удачного capture не повторять fetch “для красоты”

Если используешь shell/network tooling:
- ставить таймауты `15–20` секунд
- не делать циклических retry
- максимум `1` попытка direct fetch на породу в рамках одной сессии

## Capture workflow

### Step 1. Open breed page in a normal browser

Открыть нужный URL вручную как обычный пользователь:

- `https://www.freeads.co.uk/dog-breeds/american-cocker-spaniel`
- `https://www.freeads.co.uk/dog-breeds/rottweiler`
- `https://www.freeads.co.uk/dog-breeds/jack-russell`

Подождать, пока:
- challenge пропустит
- страница действительно покажет breed facts

### Step 2. Copy only the structured fields we need

Для raw snapshot минимально нужны:

- `summary`
- `Breed Size`
- `Breed group`
- `Other names`
- `Lifespan`
- `Weight`
- `Height`
- `Health tests available`

Из блока `Characteristics`:
- `Exercise needs`
- `Easy to train`
- `Shedding`
- `Grooming needs`
- `Good with Children`
- `Health of breed`
- `Cost to keep`
- `Intelligence`
- `Tolerates being alone`

Если чего-то нет на странице:
- оставлять `null`
- не додумывать значения

### Step 3. Save HTML, not fields

Лучше сохранять не только переписанные поля, а полный HTML page source.

Есть два пути:

1. Через helper script:

```bash
python3 tool/backend_specs/capture_freeads_html.py --breed-id rottweiler
```

2. Или вручную сохранить page source в:

- `docs/backend/import_candidates/freeads_html/freeads.<slug>.html`

### Step 4. Convert HTML into raw snapshot JSON

После этого raw snapshot можно собрать автоматически:

```bash
python3 tool/backend_specs/parse_freeads_html.py --breed-id rottweiler
```

Скрипт сам:
- поставит `urlStatus = verified_via_browser_capture`
- вытащит `summary`
- вытащит `facts`
- вытащит `characteristics`
- обновит `freeads.<slug>.json`

### Step 5. Regenerate downstream artifacts

После обновления raw snapshot:

```bash
python3 tool/backend_specs/generate_freeads_candidates.py --manifest docs/backend/import_candidates/freeads_phase1_manifest.v1.json --output-dir docs/backend/import_candidates/freeads_candidates
python3 tool/backend_specs/generate_freeads_review_pack.py
flutter test test/backend_specs/examples_json_validation_test.dart
```

### Step 6. Review the output

Смотреть:
- `docs/backend/import_candidates/freeads_candidates/candidate.<breedId>.json`
- `docs/backend/import_candidates/freeads_review_pack/review.<breedId>.json`

Хороший результат capture:
- `contentReady = true`
- есть `summaryShort`
- есть хотя бы `3` trait labels
- `review pack` уже не полностью пустой по compare fields

## Raw snapshot checklist

Перед сохранением проверить:

- `source.url` правильный
- `source.urlStatus = verified_via_browser_capture`
- `identity.slug` совпадает с manifest
- `summary` не пустой, если на странице был intro text
- `characteristics` заполнены только тем, что реально видно на странице
- нет reviewer-интерпретаций внутри raw snapshot

## What not to do

Не нужно:
- переписывать summary в “красивый продуктовый текст” на raw этапе
- выводить missing values логикой `ну наверное это large/high`
- смешивать `Freeads` raw facts и canonical `PetWise attributes`
- запускать агрессивный scraper или множественные retry по breed page

## Exit condition for one breed

Capture по породе считается успешным, если:
- raw snapshot обновлён до usable state
- candidate и review pack пересобраны
- JSON validation прошла

После этого порода может переходить в следующий reviewed pass.
