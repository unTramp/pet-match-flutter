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
- [breed.beagle.json](./examples/breed.beagle.json)
- [breed.bichon_frise.json](./examples/breed.bichon_frise.json)
- [breed.australian_shepherd.json](./examples/breed.australian_shepherd.json)
- [breed.siberian_husky.json](./examples/breed.siberian_husky.json)
- [breed.boxer.json](./examples/breed.boxer.json)
- [breed.chihuahua.json](./examples/breed.chihuahua.json)
- [breed.maltese.json](./examples/breed.maltese.json)
- [breed.pug.json](./examples/breed.pug.json)
- [breed.yorkshire_terrier.json](./examples/breed.yorkshire_terrier.json)
- [breed.jack_russell_terrier.json](./examples/breed.jack_russell_terrier.json)
- [breed.english_cocker_spaniel.json](./examples/breed.english_cocker_spaniel.json)
- [breed.american_cocker_spaniel.json](./examples/breed.american_cocker_spaniel.json)
- [breed.rottweiler.json](./examples/breed.rottweiler.json)
- [breed.doberman.json](./examples/breed.doberman.json)
- [catalog.v1.json](./examples/catalog.v1.json)

Показывает:

- canonical breed structure
- normalized attributes
- flags
- content block
- quality metadata
- starter mini-catalog for ranking checks
- first imported phase from `pets_json`/`normalized_pets`

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
- [ranking_case.apartment_low_shedding_trainable.json](./examples/ranking_case.apartment_low_shedding_trainable.json)
- [ranking_case.small_calm_apartment.json](./examples/ranking_case.small_calm_apartment.json)
- [ranking_case.low_shedding_small_family.json](./examples/ranking_case.low_shedding_small_family.json)
- [ranking_case.tiny_apartment_budget.json](./examples/ranking_case.tiny_apartment_budget.json)
- [ranking_case.active_family_house.json](./examples/ranking_case.active_family_house.json)
- [ranking_case.active_grooming_spaniel.json](./examples/ranking_case.active_grooming_spaniel.json)
- [ranking_case.large_guardian_house.json](./examples/ranking_case.large_guardian_house.json)

Показывают:

- representative user scenarios
- expected top breed
- acceptable top-3 group
- relative ordering assertions for backend tests
- comparator-sensitive scenario without false penalty for extra apartment fit
- imported sporting and guardian branches covered by explicit ranking scenarios
