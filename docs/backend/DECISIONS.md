# PetWise Backend Decisions

## Matching V1

### Принятые решения

- Квиз не выбирает породу напрямую.
- Квиз собирает `user_profile`.
- Backend ранжирует породы детерминированно по `breed catalog`.
- AI не участвует в `runtime scoring`.
- AI используется только для `breed data enrichment` и текстового контента результата.
- `question_definition`, `answer_to_profile_mapping` и `scoring_config` должны быть `config-driven`.
- Критические критерии не просто влияют на score, а могут ограничивать максимум результата.
- Результат должен содержать не только `matchPercent`, но и `label`, `summary`, `strongMatches`, `weakMatches`, `warning`.

### Что фиксируем для V1

- Фокус только на `dog` flow.
- Каталог: `30-50` популярных пород.
- Базовые атрибуты в шкале `1..5`.
- Основа алгоритма: `weighted distance`.
- Приоритеты пользователя усиливают веса.
- Верхний `display cap`: не показывать `100%`.
- В ответах и аналитике нужны версии:
  - `questionnaireVersion`
  - `scoringVersion`

### Что откладываем

- Runtime AI ranking.
- Сложные ML/LLM-рекомендации в рантайме.
- Поддержку кошек в первой итерации, если это тормозит `dog` flow.
- Слишком сложные бонусные формулы, если их трудно объяснить и дебажить.

### Что обязательно утвердить до реализации

1. Список `breed_attributes`.
2. Шкалу и смысл каждого поля.
3. `question_definition`.
4. `answer_to_profile_mapping`.
5. `scoring_config v1`.
6. `match_result` contract.

### Главный принцип V1

- Сначала делаем систему объяснимой, стабильной и калибруемой.
- Только потом делаем ее умнее.
