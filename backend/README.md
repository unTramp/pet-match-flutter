# PetWise Backend Skeleton

Этот каталог содержит минимальный server-side skeleton для нового backend-а `PetWise`.

Цель:

- не зависеть от legacy `pet-match` backend logic
- поднять реальные HTTP endpoint-ы поверх нашего reference pipeline
- иметь живой baseline для будущей production backend-реализации
- держать runtime-домен отдельным от `tool/backend_specs`

## Endpoints

- `GET /health`
- `GET /ready`
- `GET /questionnaire/definition`
- `POST /questionnaire/profile`
- `POST /match/preview`
- `GET /matches/{resultId}`
- `GET /breeds/{breedId}`

## Run

Из корня репозитория:

```bash
HOME=/private/tmp DART_SUPPRESS_ANALYTICS=true dart run backend/bin/server.dart
```

По умолчанию сервер слушает `127.0.0.1:8080` в `development`.

Можно переопределить порт:

```bash
HOME=/private/tmp DART_SUPPRESS_ANALYTICS=true dart run backend/bin/server.dart --port 9090
```

Можно переопределять runtime и через env:

```bash
export PETWISE_HOST=0.0.0.0
export PETWISE_PORT=8080
export PETWISE_ENV=production
export PETWISE_LOG_LEVEL=info
export PETWISE_STORAGE_DRIVER=file
export PETWISE_STORAGE_PATH=/srv/petwise/data
export PETWISE_EXPOSE_ERROR_DETAILS=false
HOME=/private/tmp DART_SUPPRESS_ANALYTICS=true dart run backend/bin/server.dart
```

Шаблон env лежит в [backend/config/runtime.env.example](/Users/andreydorofeev/Development/CLAUDE/pet-match/backend/config/runtime.env.example:1).

## Notes

- Это всё ещё reference skeleton, а не production-ready backend.
- Runtime domain теперь живёт в `backend/src/domain`, а `tool/backend_specs` работает как wrapper над ним.
- Текущая persistence implementation file-backed и читает данные из `docs/backend/examples` и `docs/backend/config`.
- Runtime match results сейчас сохраняются в file-backed storage по пути `PETWISE_STORAGE_PATH/match_results`.
- Подготовлен переключаемый persistence bootstrap `file/postgres`, но `postgres` пока scaffold-only и честно падает fast-fail до подключения реального драйвера.
- Включены structured JSON logs, `health/readiness` и env-based runtime config.
- `500`-ответы больше не отдают внутренние пути к spec-файлам.
- Explanation payload всё ещё минимальный и нужен как baseline, а не как финальный product copy.
