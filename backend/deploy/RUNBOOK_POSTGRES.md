# Postgres Runbook

Этот runbook описывает первый живой запуск `PetWise` backend в hybrid-режиме:

- immutable specs читаются из `docs/backend/...`
- `StoredMatchResult` сохраняется в Postgres

## Requirements

- Docker и Docker Compose установлены на машине
- `nginx` из compose должен быть доступен хотя бы на одном локальном порту
- `jq` и `curl` установлены для smoke test

## 1. Prepare env

Из каталога [backend/deploy](/Users/andreydorofeev/Development/CLAUDE/pet-match/backend/deploy:1):

```bash
cp .env.example .env
```

Проверь `.env`:

- `PETWISE_STORAGE_DRIVER=postgres`
- `DATABASE_URL=postgres://petwise:petwise@postgres:5432/petwise?sslmode=disable`

Если нужен другой домен или пароль:

- меняем `DATABASE_URL`
- синхронно меняем `POSTGRES_*` в `docker-compose.yml`

## 2. Build and start

Из каталога `backend/deploy`:

```bash
docker compose up -d --build
```

Проверить контейнеры:

```bash
docker compose ps
```

Проверить логи backend:

```bash
docker compose logs -f petwise-backend
```

В логах ожидаем:

- `persistence.bootstrap`
- `driver=postgres`
- `server.started`

## 3. Health checks

Через `nginx`:

```bash
curl -sS http://127.0.0.1:8081/health | jq
curl -sS http://127.0.0.1:8081/ready | jq
```

Ожидаем:

- `/health.status == "ok"`
- `/ready.status == "ready"`

## 4. End-to-end smoke test

Запустить helper script:

```bash
BASE_URL=http://127.0.0.1:8081 sh backend/deploy/smoke-test.sh
```

Скрипт делает:

1. ждёт `health`
2. берёт baseline из `docs/backend/examples/answers.apartment_quiet_beginner.json`
3. вызывает `POST /questionnaire/profile`
4. вызывает `POST /match/preview`
5. читает `GET /matches/{resultId}`
6. проверяет, что сохранённый `match_result` читается обратно

Если хочешь дополнительно зафиксировать ожидаемый top breed для конкретного baseline:

```bash
BASE_URL=http://127.0.0.1:8081 EXPECTED_TOP_BREED=whippet sh backend/deploy/smoke-test.sh
```

Если сервис доступен не на localhost:

```bash
BASE_URL=http://your-host sh backend/deploy/smoke-test.sh
```

Если хочешь прогнать другой answer fixture:

```bash
BASE_URL=http://127.0.0.1:8081 \
ANSWERS_FIXTURE_PATH=docs/backend/examples/answers.family_friendly.json \
sh backend/deploy/smoke-test.sh
```

## 5. Verify Postgres persistence

Проверка через контейнер Postgres:

```bash
docker compose exec postgres psql -U petwise -d petwise -c "select id, top_breed_id, top_match_percent, created_at from stored_match_results order by created_at desc limit 5;"
```

Ожидаем хотя бы одну запись после smoke test.

## 6. Hetzner rollout order

Я бы делал так:

1. поднять чистую Ubuntu VM
2. установить Docker и Compose plugin
3. скопировать репозиторий в `/srv/petwise/app`
4. перейти в `backend/deploy`
5. подготовить `.env`
6. сделать `docker compose up -d --build`
7. прогнать `smoke-test.sh`
8. только после этого привязывать домен и TLS

## 7. Rollback

Остановить стек:

```bash
docker compose down
```

Остановить без удаления volumes:

```bash
docker compose stop
```

Полный reset данных:

```bash
docker compose down -v
```

Последнюю команду использовать осторожно: она удаляет Postgres volume.
