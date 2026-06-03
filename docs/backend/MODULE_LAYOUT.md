# PetWise Backend Module Layout

## Goal

Предложить минимальную backend-структуру, которая хорошо поддерживает:

- questionnaire flow
- config-driven profile building
- deterministic scoring
- breed catalog enrichment

## Suggested modules

### `questionnaire`

Responsibilities:

- return active questionnaire definition
- validate incoming answers
- expose questionnaire version

Main inputs:

- `questionnaire_definitions`

Main outputs:

- questionnaire payload
- validated answers payload

### `profile-builder`

Responsibilities:

- load `answer_to_profile_mapping`
- transform answers into canonical `user_profile`
- populate `criticalContext`

Main inputs:

- questionnaire answers
- mapping config

Main outputs:

- `user_profile`

### `breed-catalog`

Responsibilities:

- return canonical breed cards
- expose normalized attributes
- separate raw enrichment lifecycle from runtime reads

Main inputs:

- `breeds`
- `breed_attributes`
- `breed_content`

Main outputs:

- breed entities for ranking and details pages

### `matching-engine`

Responsibilities:

- load `scoring_config`
- compute weighted distance
- apply critical caps
- apply priority boosts and bonuses
- rank breeds

Main inputs:

- `user_profile`
- breed catalog
- scoring config

Main outputs:

- ranked candidates

### `explanation-builder`

Responsibilities:

- build human-readable `summary`
- derive `strongMatches`
- derive `weakMatches`
- attach warnings and caveats

Main inputs:

- ranked candidate
- user profile
- breed content

Main outputs:

- explanation payload for `match_result`

### `match-result`

Responsibilities:

- assemble final result contract
- attach `questionnaireVersion`
- attach `scoringVersion`
- optionally attach `debug`

Main inputs:

- ranked candidates
- user profile
- explanation payload

Main outputs:

- `match_result`

## Suggested request flow

1. `questionnaire` returns active question set.
2. client submits answers.
3. `profile-builder` creates `user_profile`.
4. `matching-engine` ranks breeds.
5. `explanation-builder` enriches result.
6. `match-result` returns final payload.

## Suggested directory layout

```txt
src/
  modules/
    questionnaire/
    profile-builder/
    breed-catalog/
    matching-engine/
    explanation-builder/
    match-result/
  shared/
    config/
    contracts/
    types/
```

## Boundaries

- UI or mobile app should not know internal scoring rules.
- `matching-engine` should not call AI.
- AI enrichment pipeline should not be part of runtime request flow.
- config loading should be centralized and version-aware.
