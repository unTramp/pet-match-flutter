# PetWise — Project Guide

## Project overview

This is a Flutter mobile application for AI-powered pet matching.

Primary user flow:

Welcome → Intro → Questionnaire → Analyzing → Result → Breed Details → Gallery

The app is Android-first, but code should remain cross-platform where practical.

## Architecture

The project uses Clean Architecture with a layer-first structure:

- `lib/core` — shared infrastructure, design system, routing, networking, DI, storage, utils
- `lib/data` — DTOs, mappers, network helpers, sources, repository implementations
- `lib/domain` — entities, repository contracts, use cases
- `lib/presentation` — screens, widgets, Cubits, router, UI experiments

Do not introduce a new `features/` architecture unless explicitly requested.
Follow the existing layer-first structure.

## Current project structure

Important directories:

- `lib/core/design/components` — shared UI components
- `lib/core/design/tokens` — spacing, radius, motion, shadows, sizes, strokes, alpha
- `lib/core/theme` — app colors and theme
- `lib/core/di/injection.dart` — dependency registration
- `lib/core/routing/app_routes.dart` — route constants
- `lib/core/network` — shared network-level helpers if applicable
- `lib/core/storage` — local storage abstractions
- `lib/data/dto` — API DTO models
- `lib/data/mappers` — DTO to domain mapping
- `lib/data/network` — network clients/interceptors/helpers
- `lib/data/repositories` — repository implementations
- `lib/data/sources` — remote sources and endpoints
- `lib/domain/entities` — domain entities
- `lib/domain/repositories` — repository interfaces
- `lib/domain/usecases` — application use cases
- `lib/presentation/router` — `go_router` configuration
- `lib/presentation/questionnaire` — questionnaire flow
- `lib/presentation/result` — result screen
- `lib/presentation/details` — breed detail and gallery screens
- `lib/presentation/intro` — intro flow
- `lib/presentation/welcome` — welcome/start screen
- `lib/presentation/widgets` — shared presentation widgets
- `lib/presentation/dev` — development-only screens and experiments
- `lib/presentation/test` — preview/demo/test UI screens

## Tech stack

- Flutter 3.x
- Dart 3.x
- State management: `flutter_bloc` with Cubit
- Navigation: `go_router`
- Dependency Injection: `get_it`
- Networking: `dio` with interceptors
- Local session storage: `SharedPreferences`
- Error handling: typed `AppFailure`

## Core engineering rules

1. Analyze existing code before making changes.
2. Respect current architecture and naming.
3. For architecture, data, navigation, or state changes:
   - think through the implementation first
   - provide a short implementation plan when the change is non-trivial
4. For UI-only changes:
   - prefer fast iteration
   - do not over-engineer abstractions
   - keep experiments inside presentation
5. Keep business logic out of widgets.
6. Use Cubit for screen state when stateful screen behavior is needed.
7. Use use cases for application actions that belong to domain behavior.
8. Use repositories as contracts between domain and data.
9. Use DTOs only in the data layer.
10. Map DTOs to domain entities through mappers.
11. Do not expose DTOs to presentation.
12. Do not call Dio directly from presentation.
13. Do not create unnecessary abstractions.
14. Do not modify generated files manually.
15. Prefer small reusable widgets over large build methods once UI patterns stabilize.

## UI Iteration Mode

This project actively explores UX, information hierarchy, and visual design.

When working on UI:

- prioritize visual quality
- prioritize usability
- preserve design consistency
- suggest alternatives when appropriate
- prefer fast iteration over premature abstraction
- keep UI experiments inside presentation when possible
- do not introduce new architectural layers for UI-only changes
- avoid moving temporary visual experiments into domain or data layers

For UI-only tasks:

- it is acceptable to iterate directly in widgets/components first
- a formal implementation plan is optional unless the change has broad impact
- small reusable widgets are preferred when UI patterns begin repeating
- refactor only after the visual direction becomes stable

Rapid UI iteration is preferred over excessive abstraction.

## UI change scope

When implementing UI review recommendations:

- prefer small focused iterations
- implement only approved recommendations
- avoid combining multiple UX experiments in one change
- keep visual scope intentionally narrow

For UI reviews:

1. identify recommendations
2. decide which recommendations are accepted
3. implement only accepted recommendations
4. validate visually
5. measure results before further iteration

Do not implement every recommendation from a review automatically.

## Product-first decision making

When multiple solutions are possible:

1. Prefer the solution that improves user experience.
2. Prefer the solution that improves clarity.
3. Prefer the solution that improves maintainability.
4. Prefer the solution that reduces complexity.

Do not introduce architecture, abstractions, or state management
unless there is a clear product or engineering benefit.

The goal is not maximum architectural purity.

The goal is a product that feels:

- simple
- premium
- trustworthy
- easy to understand
- easy to extend

## ROI rule

Prefer improvements with the highest user value and lowest implementation risk.

When multiple improvements are available:

- prioritize clarity over decoration
- prioritize usability over visual novelty
- prioritize product value over architectural perfection

Small improvements with clear user impact are preferred over large refactors with uncertain value.

### Visual validation

For UI-heavy changes:

- verify visually on the affected screens
- verify navigation flows
- verify loading/error states if applicable
- verify small screen layouts
- verify long text handling

### Practical guidance

- Keep architectural changes deliberate.
- Keep UI changes fast and iterative.
- Reuse the design system before creating new primitives.
- Do not over-abstract temporary visual experiments.
- Refactor repeated UI patterns once the direction is validated.
- Optimize for a product that feels coherent, premium, and easy to scan.

Before creating a new shared widget:

- check existing design-system components
- check presentation/widgets
- check result/widgets
- extend existing components when practical

Avoid creating multiple widgets that solve the same problem.

## UI and design rules

The app should feel soft, premium, modern, and pet-friendly.

Use existing design system components and tokens where possible:

- `UiButton`
- `UiCard`
- `UiStateView`
- `AppStaggeredEntrance`
- `BreedMiniGauge`
- `BreedStoryAvatar`
- `AnimatedScoreLabel`

Use design tokens from:

- `spacing.dart`
- `radius.dart`
- `motion.dart`
- `shadows.dart`
- `sizes.dart`
- `strokes.dart`
- `alpha.dart`

Do not hardcode spacing, radius, shadows, or motion values if a token already exists.

Prefer:

- rounded cards
- soft shadows
- purple accents
- clean mobile layout
- readable text hierarchy
- smooth but restrained animations

Avoid:

- visual overload
- too many icons in one section
- inconsistent paddings
- business logic inside UI widgets

## Error handling rules

The project uses typed failures through `AppFailure`.

When adding networking or repository logic:

- map Dio/network exceptions through the existing failure mapping approach
- return typed failures instead of raw exceptions
- make UI states explicit: loading, success, empty, error
- provide retry actions where appropriate
- never leave the screen in infinite loading after an error

## State management rules

Use Cubit for presentation state.

State should be:

- explicit
- immutable where possible
- easy to test
- not overloaded with raw API models

For new screens with real screen-level state, create:

- page widget
- Cubit
- state
- private/reusable widgets if needed

Follow existing examples:

- `questionnaire_cubit.dart`
- `questionnaire_state.dart`
- `breed_detail_cubit.dart`
- `breed_detail_state.dart`

Do not introduce Cubit for purely local decorative UI state unless screen-level state management is actually needed.

## Navigation rules

Use `go_router`.

Route constants belong in:

- `lib/core/routing/app_routes.dart`

Router configuration belongs in:

- `lib/presentation/router/app_router.dart`

Do not hardcode route strings directly in widgets if a route constant exists.

## Dependency injection rules

Use `get_it`.

Register dependencies in:

- `lib/core/di/injection.dart`

When adding a new use case, repository implementation, source, or Cubit dependency, update DI accordingly.

UI-only widgets do not need DI unless they depend on application services.

## Data layer rules

For API work:

- add DTOs in `lib/data/dto`
- add mappers in `lib/data/mappers`
- add endpoints in `lib/data/sources/endpoints.dart`
- add remote source methods in `petwise_remote_source.dart`
- implement HTTP calls in `http_petwise_remote_source.dart`
- keep mock behavior in `mock_petwise_remote_source.dart` if applicable
- implement repositories in `lib/data/repositories`

## Domain layer rules

Domain layer should stay framework-independent.

Use:

- entities in `lib/domain/entities`
- repository contracts in `lib/domain/repositories`
- use cases in `lib/domain/usecases`

Do not import Flutter widgets, Dio, DTOs, or presentation classes into domain.

## Presentation rules

Presentation layer contains:

- pages
- widgets
- Cubits
- states
- router
- UI previews and experiments

Presentation can depend on domain and core UI.
Presentation must not depend directly on DTOs or Dio.

Temporary UI experiments are acceptable in presentation as long as they do not leak into domain or data.

## Result screen note

The `Result` screen is an active product-design iteration area.

When updating it:

- prioritize clarity of recommendation
- keep strong hierarchy between hero, summary, traits, and alternatives
- avoid duplicating the same information in multiple visual forms
- prefer honest data presentation over artificial prioritization
- if backend priority/relevance is unavailable, do not imply ranking that the data does not support

## Backend contract status

Some areas of the application are intentionally temporary
until backend contracts are finalized.

Current examples:

- breed characteristics
- breed requirements
- some Result screen data structures
- recommendation metadata

When backend contracts are not finalized:

- avoid creating complex domain abstractions
- avoid speculative repository interfaces
- avoid premature DTO/domain modeling

Prefer lightweight UI-level solutions and TODO markers.

Once backend contracts become stable:

-  align DTOs
- align domain entities
- align repository contracts
- remove temporary UI-only data structures


## Git workflow

This project uses Git as the primary safety mechanism for experimentation and refactoring.

### Branching

For non-trivial changes:

- create a dedicated branch before implementation
- keep one branch focused on one task
- avoid mixing unrelated changes

Examples:

- `fix/router-preview-separation`
- `fix/mock-mode-release-safety`
- `refactor/result-page-decomposition`
- `feat/favorites-ui`
- `chore/design-tokens-cleanup`

### Working tree safety

Before starting a non-trivial task:

- check git status
- identify uncommitted changes
- warn if the working tree is not clean

Do not mix new work with unrelated uncommitted changes.

If the repository contains significant local modifications:

- explain the situation
- suggest creating a commit or checkpoint first
- wait for confirmation before proceeding


### Commits

Prefer small atomic commits.

Do not mix:

- refactoring
- feature development
- design changes
- infrastructure changes

in a single commit.

Examples:

- `fix: prevent mock mode in release builds`
- `fix: isolate preview routes from production router`
- `refactor: extract result page summary section`
- `chore: move gauge colors to design tokens`
- `test: add breed mini gauge widget tests`

### Safe refactoring

Before modifying more than 3 files:

- show affected files
- explain intended changes

Before modifying more than 10 files:

- create a dedicated branch
- provide implementation plan
- wait for confirmation

When performing refactoring:

- preserve existing behavior
- preserve existing visual appearance unless explicitly requested
- separate refactoring from redesign work

Refactoring should not introduce visual changes.

### Validation before commit

Before creating a commit:

```bash
flutter analyze
flutter test
```

If tests fail:

- do not commit
- explain failures
- propose fixes

### Commit policy for AI agents

AI agents may:

- create branches
- show diffs
- propose commit messages

AI agents must NOT:

- push to remote repositories
- merge branches
- create commits without explicit confirmation
- rewrite git history without explicit confirmation

After implementation:

1. show modified files
2. summarize changes
3. propose commit message
4. wait for confirmation before committing


## Testing and validation

## Testing policy

Tests should provide confidence without slowing down UI iteration.

### Required

For changes affecting:

- routing
- dependency injection
- repositories
- use cases
- state management (Cubit)
- business rules

add or update tests unless there is a documented reason not to.

### Recommended

For reusable UI components:

- widget tests are encouraged
- especially for shared design-system components

Examples:

- BreedMiniGauge
- BreedStoryAvatar
- UiButton
- UiCard

### Not required

For temporary UI experiments, prototypes, and rapidly changing screens:

- tests may be postponed
- visual validation is acceptable

Examples:

- presentation/dev
- presentation/test
- active design exploration inside Result and Breed Details

### Rule of thumb

If a bug in the change would be expensive to discover manually,
consider adding a test.

If the UI is still actively evolving,
prefer stabilizing the design before investing heavily in tests.


After implementation, run:

```bash
flutter analyze
flutter test
```
