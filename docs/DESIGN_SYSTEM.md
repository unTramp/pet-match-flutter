# Design System Guide

This project uses a lightweight UIKit approach with centralized tokens and shared components.

## Goals

1. Keep visuals consistent across screens.
2. Reduce duplicated UI code.
3. Make new features faster to implement.
4. Keep design changes low-risk.

## Layers

1. Tokens: `lib/core/design/tokens/`
2. Content strings: `lib/core/design/content/`
3. Components: `lib/core/design/components/`
4. Feature widgets/screens: `lib/presentation/**`

## Tokens

Use tokens instead of hardcoded values:

1. Spacing: `AppSpacing`
2. Radius: `AppRadius`
3. Motion: `AppMotion`
4. Colors: `AppColors`
5. Theme typography: `Theme.of(context).textTheme`

## Strings

User-facing text should come from:

`lib/core/design/content/app_strings.dart`

Rules:

1. Do not add new hardcoded business copy directly in screens when a shared key fits.
2. Keep strings grouped by feature (`welcome`, `intro`, `questionnaire`, `result`, `details`).

## Components

Prefer shared components before creating local variants:

1. `UiCard` for section/card containers.
2. `UiStateView` for loading/error/empty states.
3. `UiButton` for standard action buttons.
4. `GradientButton` for branded CTA only.

## Contribution Rules

1. Prefer tokens over raw numbers for spacing/radius/duration.
2. Keep business logic outside UI primitives.
3. Add or update widget tests when changing shared components.
4. Run:
   - `flutter analyze`
   - `flutter test` (at least affected suites)

## When to Add a New Shared Component

Create a shared component only if one of these is true:

1. The same UI pattern appears in 3+ places.
2. The pattern has variants that should stay visually consistent.
3. The pattern carries common behavior (loading/disabled/error interactions).

Otherwise keep it local to feature scope.
