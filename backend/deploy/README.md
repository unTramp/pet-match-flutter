# Hetzner Deploy Scaffold

Этот каталог подготавливает shape для запуска нового backend-а на Hetzner.

Что здесь есть:

- `Dockerfile` — базовый container build для текущего монорепо
- `docker-compose.yml` — пример связки `backend + postgres + nginx`
- `.env.example` — стартовый runtime env для compose
- `RUNBOOK_POSTGRES.md` — пошаговый запуск и проверка hybrid postgres mode
- `smoke-test.sh` — smoke test для `health/profile/match/persisted result`
- `nginx/petwise-backend.conf` — reverse proxy конфиг
- `systemd/petwise-backend.service` — пример unit-файла для bare-metal запуска

## Important note

Сейчас backend живёт внутри общего Flutter-репозитория и использует общий `pubspec.yaml`.
Поэтому Docker image пока опирается на Flutter SDK image, а не на лёгкий `dart` image.

Это нормальный промежуточный этап.
Когда backend будет вынесен в отдельный package/repo, image можно будет сильно облегчить.

## Deployment modes

### 1. Docker Compose on Hetzner

Подходит как ближайший practical path:

- копируем репозиторий на сервер
- копируем `.env.example` в `.env` и правим секреты
- поднимаем `docker compose up -d --build`

### 2. systemd + local process

Подходит, если хочешь запускать backend как обычный сервис без контейнеров:

- ставим Flutter SDK на сервер
- делаем `flutter pub get`
- запускаем `dart run backend/bin/server.dart`
- оборачиваем в `systemd`
- ставим `nginx` перед приложением

## Required env

- `PETWISE_HOST`
- `PETWISE_PORT`
- `PETWISE_ENV`
- `PETWISE_LOG_LEVEL`
- `PETWISE_STORAGE_DRIVER`
- `PETWISE_STORAGE_PATH`
- `PETWISE_QUESTIONNAIRE_VERSION`
- `PETWISE_SCORING_VERSION`
- `PETWISE_CATALOG_VERSION`
- `PETWISE_EXPOSE_ERROR_DETAILS`
- `DATABASE_URL`

Для текущего состояния рекомендуемый runtime:

- для самого простого старта можно оставить `PETWISE_STORAGE_DRIVER=file`
- для нового live adapter path можно использовать `PETWISE_STORAGE_DRIVER=postgres`

Когда будет подключён реальный Postgres adapter:

- `PETWISE_STORAGE_DRIVER=postgres`
- `DATABASE_URL=postgres://...`

Важно:

- текущий Postgres path уже реализован для `StoredMatchResult`
- immutable spec data пока всё ещё file-backed
- это осознанный hybrid режим, чтобы не мигрировать весь catalog в БД одним шагом
