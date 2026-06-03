# PetWise Scoring Config

## Goal

Сделать ранжирование:

- детерминированным
- объяснимым
- калибруемым
- версионируемым

## V1 algorithm

1. Build `effectiveWeights` from `baseWeights` and `userProfile.priorities`.
2. Compute `weightedPenalty` with field-specific comparators.
3. Compute `maxPossiblePenalty` on the same fields.
4. Normalize to `baseScore = 1 - weightedPenalty / maxPossiblePenalty`.
5. Apply `criticalCaps`.
6. Apply profile-conflict confidence cap when `userProfile.profileDiagnostics.conflicts` is not empty.
7. Add `priorityBonus`.
8. Convert to percent and apply `displayCap`.
9. Resolve `label`.

## Comparators

Не все поля должны штрафоваться симметрично.

- `symmetric`: обычная дистанция `abs(user - breed)`
- `atLeast`: порода не должна быть ниже потребности пользователя
- `atMost`: порода не должна быть выше толерантности пользователя

Примеры:

- `apartmentSuitability=atLeast`
- `goodWithChildren=atLeast`
- `exerciseNeeds=atMost`
- `groomingNeeds=atMost`
- `noiseLevel=atMost`

Это убирает ложные штрафы за “избыточно хороший” fit, например когда
apartment-friendly breed показывается пользователю с домом и двором.

## Base weights

Suggested V1 weights:

```json
{
  "size": 4,
  "exerciseNeeds": 5,
  "apartmentSuitability": 5,
  "aloneTolerance": 5,
  "goodWithChildren": 5,
  "goodWithOtherPets": 4,
  "groomingNeeds": 3,
  "sheddingLevel": 3,
  "beginnerFriendly": 6,
  "maintenanceCost": 3,
  "noiseLevel": 3
}
```

`size` считается отдельно от numeric-полей: user profile хранит `sizePreference` как список допустимых размеров, а penalty берется как расстояние до ближайшего допустимого значения.

## Priority boosts

Suggested V1 boosts:

```json
{
  "trainable": {
    "trainability": 4
  },
  "apartment_friendly": {
    "apartmentSuitability": 2
  },
  "low_grooming": {
    "groomingNeeds": 2,
    "sheddingLevel": 1
  },
  "quiet": {
    "noiseLevel": 2
  },
  "active_companion": {
    "exerciseNeeds": 2
  },
  "calm_temperament": {
    "temperamentCalm": 2
  }
}
```

## Priority target values

Некоторые приоритеты должны не только усиливать вес, но и задавать целевое значение, если у пользователя нет отдельного numeric-поля в `user_profile`.

Это особенно важно для:

- `trainable`
- `calm_temperament`
- `quiet`

Suggested V1 targets:

```json
{
  "trainable": {
    "trainability": 5
  },
  "good_with_children": {
    "goodWithChildren": 5
  },
  "apartment_friendly": {
    "apartmentSuitability": 5
  },
  "low_grooming": {
    "groomingNeeds": 1,
    "sheddingLevel": 1
  },
  "quiet": {
    "noiseLevel": 1,
    "temperamentCalm": 5
  },
  "alone_tolerance": {
    "aloneTolerance": 5
  },
  "active_companion": {
    "exerciseNeeds": 5
  },
  "calm_temperament": {
    "temperamentCalm": 5
  }
}
```

## Critical caps

Critical criteria should cap the maximum result if they are clearly mismatched.

Suggested V1 rules:

- If `livesInApartment = true` and `breed.apartmentSuitability <= 2`, cap at `70`.
- If `hasYoungChildren = true` and `breed.goodWithChildren <= 2`, cap at `65`.
- If `hasOtherPets = true` and `breed.goodWithOtherPets <= 2`, cap at `68`.
- If user requires `aloneTolerance >= 4` and breed value `<= 2`, cap at `72`.
- If user strongly needs beginner fit (`beginnerFriendly >= 4`) and breed value `<= 2`, cap at `76`.

## Profile conflict cap

Если questionnaire-ответы противоречат друг другу, это не означает, что нужно
полностью отменять матчинг. Но это означает, что результат должен быть менее
уверенным.

Suggested V1 behavior:

- builder записывает `userProfile.profileDiagnostics.conflicts`
- matcher применяет `profileConflictCap`
- frontend/backend explanation добавляет risk message про противоречивые ответы

Это позволяет честно показывать: подбор выполнен, но ввод пользователя шумный.

## Display cap and labels

```json
{
  "displayCap": 96,
  "labels": [
    { "min": 91, "label": "Идеальное совпадение" },
    { "min": 81, "label": "Отличное совпадение" },
    { "min": 71, "label": "Хорошее совпадение" },
    { "min": 61, "label": "Подойдет с оговорками" },
    { "min": 0, "label": "Есть более подходящие варианты" }
  ]
}
```

## Design rules

- Bonuses must not override critical caps.
- `100%` should never be displayed.
- Score should be reproducible for the same `user_profile`, `breed catalog` and `scoring_config version`.
- `match_result` should return `scoringVersion`.

## Debug payload

For internal/dev usage, it is helpful to return:

- `weightsUsed`
- `criticalCapApplied`
- `baseScore`
- `priorityBonus`

This debug block should be optional in production responses.
