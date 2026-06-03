# PetWise Data Model

## Core entities

### `breed`

Хранит каноническую карточку породы.

Suggested fields:

- `id`
- `petType`
- `name`
- `aliases`
- `breedGroup`
- `status`
- `qualityVersion`
- `createdAt`
- `updatedAt`

### `breed_attributes`

Хранит нормализованные numeric attributes и flags, по которым считается score.

Required V1 attributes:

- `size`
- `apartmentSuitability`
- `exerciseNeeds`
- `aloneTolerance`
- `goodWithChildren`
- `goodWithOtherPets`
- `groomingNeeds`
- `sheddingLevel`
- `beginnerFriendly`
- `maintenanceCost`

Optional V1.1 attributes:

- `noiseLevel`
- `trainability`
- `temperamentCalm`
- `affectionLevel`
- `healthComplexity`

Flags:

- `isVocal`
- `isHighPreyDrive`
- `isSensitive`
- `isEscapeProne`
- `isSuitableForFirstTimeOwners`

### `breed_content`

Контент, который нужен для result screen и breed details.

- `summaryShort`
- `strengths`
- `watchouts`
- `adaptationTips`
- `sourceNotes`

### `question_definition`

Определяет форму questionnaire и UX flow.

- `id`
- `order`
- `kind`
- `required`
- `title`
- `description`
- `maxSelections`
- `options`
- `questionnaireVersion`

### `answer_to_profile_mapping`

Описывает, как ответы преобразуются в `user_profile`.

- `questionId`
- `optionId`
- `effects[]`

Each effect should contain:

- `field`
- `operator`
- `value`

Supported V1 operators:

- `set`
- `allow`
- `cap_max`
- `cap_min`
- `append`

### `scoring_config`

Версионируемая конфигурация ranking engine.

- `version`
- `baseWeights`
- `priorityWeightBoosts`
- `priorityTargetValues`
- `criticalCaps`
- `displayCap`
- `labels`
- `changelogReason`
- `publishedAt`

## Runtime entities

### `user_profile`

Каноническое представление предпочтений пользователя после questionnaire.

- `petType`
- `sizePreference`
- `exerciseNeeds`
- `apartmentSuitability`
- `aloneTolerance`
- `goodWithChildren`
- `goodWithOtherPets`
- `groomingNeeds`
- `sheddingLevel`
- `beginnerFriendly`
- `maintenanceCost`
- `noiseLevel`
- `priorities`
- `criticalContext`
- `profileDiagnostics` optional

Notes:

- `sizePreference` хранится списком допустимых значений, а не одним числом.
- Профиль из questionnaire хранит только прямые ответы пользователя и `priorities`.
- Производные target values, например для `trainability` или `temperamentCalm`, резолвятся внутри matcher через `priorityTargetValues`, а не гидрируются в profile builder.
- Если ответы дают противоречивые ограничения, builder сохраняет это в `profileDiagnostics.conflicts`, а matcher применяет мягкий confidence cap вместо полного отказа.

### `match_result`

Payload, который UI рендерит на result screen.

- `resultId`
- `questionnaireVersion`
- `scoringVersion`
- `userProfile`
- `topMatch`
- `alternatives`
- `compatibility`

Notes:

- `topMatch` / `alternatives` остаются каноническим internal result shape для backend spec.
- `compatibility` — bridge-view поверх того же результата, выровненный по семантике старого клиентского `Compatibility` payload.
- `compatibility` не должен жить отдельной логикой; он собирается из того же scoring/explainability результата.

### `stored_match_result`

Persisted runtime snapshot для повторного чтения результата по `resultId`.

- `id`
- `questionnaireVersion`
- `scoringVersion`
- `topBreedId`
- `topMatchPercent`
- `userProfile`
- `resultPayload`
- `createdAt`

## Suggested storage layout

### Relational tables

- `breeds`
- `breed_attributes`
- `breed_content`
- `questionnaire_definitions`
- `answer_to_profile_mappings`
- `scoring_configs`
- `stored_match_results`

### Notes

- `questionnaire_definitions`, `answer_to_profile_mappings` and `scoring_configs` should be versioned.
- `breed_attributes` should be treated as canonical normalized data, not regenerated on every request.
- `match_result` can be computed on demand; persistence is optional for V1.
