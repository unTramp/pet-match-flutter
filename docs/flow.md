# App Flow (Current)

This document captures the current user flow after UX cleanup.

## Entry

1. `Welcome`
2. If active session exists: CTA label is `Продолжить`, otherwise `Начать`.

## Start / Continue behavior

- `Welcome` CTA and `Intro` CTA both prefetch session via `StartSession`.
- CTA shows loading while request is in flight.
- On success, app opens `Questionnaire` with prefetched `Session` in route `extra`.

## Questionnaire behavior

- No back navigation inside questionnaire (system back is blocked).
- Header is aligned with welcome style (`AppLogo` + `LanguageToggle`).
- While submitting:
  - CTA shows loading
  - answer options are non-interactive and visually dimmed
  - top thin progress line is shown

## Completion behavior

- Dedicated `Analyzing` screen is not part of questionnaire happy-path anymore.
- After last answer, compatibility polling runs inside `QuestionnaireCubit`.
- App navigates directly to `Result` when compatibility is ready.

## Resume behavior

- `StartSession` first tries `getSession(savedUserId)` if local `savedUserId` exists.
- If no saved id, it falls back to `startSession(uid:...)`.
