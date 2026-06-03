# PetWise Backend Examples

Этот файл ссылается на example payload-ы для `Matching V1`.

## Examples

### Breed

- [breed.whippet.json](./examples/breed.whippet.json)
- [breed.cavalier_king_charles_spaniel.json](./examples/breed.cavalier_king_charles_spaniel.json)
- [breed.italian_greyhound.json](./examples/breed.italian_greyhound.json)
- [breed.basenji.json](./examples/breed.basenji.json)
- [breed.border_collie.json](./examples/breed.border_collie.json)
- [breed.french_bulldog.json](./examples/breed.french_bulldog.json)
- [breed.labrador_retriever.json](./examples/breed.labrador_retriever.json)
- [catalog.v1.json](./examples/catalog.v1.json)

Показывает:

- canonical breed structure
- normalized attributes
- flags
- content block
- quality metadata
- starter mini-catalog for ranking checks

### User profile

- [user_profile.apartment_quiet.json](./examples/user_profile.apartment_quiet.json)
- [answers.apartment_quiet_beginner.json](./examples/answers.apartment_quiet_beginner.json)
- [answers.active_trainable.json](./examples/answers.active_trainable.json)
- [answers.family_friendly.json](./examples/answers.family_friendly.json)
- [profile_from_answers.apartment_quiet_beginner.json](./examples/profile_from_answers.apartment_quiet_beginner.json)

Показывает:

- результат questionnaire после mapping
- priorities
- criticalContext
- связку `answers -> built profile`
- answer fixtures for e2e scenarios

### Questionnaire definition

- [questionnaire_definition.v1.json](./examples/questionnaire_definition.v1.json)

Показывает:

- shape вопросов
- single-choice and multi-choice blocks
- versioned questionnaire payload

### Match result

- [match_result.whippet.json](./examples/match_result.whippet.json)

Показывает:

- result payload для UI
- explanation fields
- alternatives
- compatibility bridge-view for legacy/frontend mapping

### Ranking fixtures

- [ranking_case.apartment_quiet_beginner.json](./examples/ranking_case.apartment_quiet_beginner.json)
- [ranking_case.active_trainable.json](./examples/ranking_case.active_trainable.json)
- [ranking_case.family_friendly.json](./examples/ranking_case.family_friendly.json)
- [ranking_case.house_yard_quiet_beginner.json](./examples/ranking_case.house_yard_quiet_beginner.json)

Показывают:

- representative user scenarios
- expected top breed
- acceptable top-3 group
- relative ordering assertions for backend tests
- comparator-sensitive scenario without false penalty for extra apartment fit
