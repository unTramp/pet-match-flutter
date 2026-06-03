# Backend Runtime Config

Этот каталог хранит пример runtime-конфигурации для нового `PetWise` backend.

Текущая схема:

- переменные читаются через `Platform.environment`
- CLI-флаги могут переопределять env values
- default profile ориентирован на локальную разработку

Поддерживаемые переменные:

- `PETWISE_HOST`
- `PETWISE_PORT`
- `PETWISE_ENV`
- `PETWISE_LOG_LEVEL`
- `PETWISE_STORAGE_DRIVER`
- `PETWISE_QUESTIONNAIRE_VERSION`
- `PETWISE_SCORING_VERSION`
- `PETWISE_CATALOG_VERSION`
- `PETWISE_STORAGE_PATH`
- `PETWISE_EXPOSE_ERROR_DETAILS`
- `DATABASE_URL`

Для локального старта можно использовать `runtime.env.example` как шаблон.
