# Beta Release and Catalog Roadmap

This document freezes the current working rhythm before we switch focus from
catalog expansion to beta readiness.

## Current State

- Current release target: dog-only beta.
- Current canonical dog catalog: `56` breeds.
- Current Freeads mapping status: `56 mapped / 0 unresolved`.
- Current ingestion style: reviewed Freeads imports, not direct source copies.
- Current product posture: good enough for a first dog matching beta, then expand
  the catalog in updates.

## Beta Scope

Ship the first beta as a focused dog matching product:

- Welcome -> Intro -> Questionnaire -> Result -> Breed Details -> Gallery.
- Dog-only questionnaire and result flow.
- Current reviewed dog catalog.
- Story avatars and backend media serving.
- Deterministic matching engine with ranking fixtures.

Do not include cats in the beta flow until there is a separate cat catalog,
questionnaire review and scoring validation pass.

## Why This Is Enough For Beta

The catalog already covers the major practical dog ownership branches:

- toy and tiny apartment companions
- low-shedding small companions
- terriers
- sporting and high-drive breeds
- family-friendly large dogs
- giant calm breeds
- guardian and working breeds
- vocal/spitz/herding profiles
- low-energy apartment options

The important thing now is not reaching all Freeads breeds before first release.
The higher ROI step is making the existing result experience feel trustworthy,
data-driven and polished.

## UI Readiness Focus

Pause aggressive breed imports while beta UX is hardened.

Recommended first UI items:

1. Make `CharacteristicsSection` data-driven.
   Current issue: result characteristics are still hardcoded in
   `lib/presentation/result/widgets/characteristics_section.dart`.
   Desired behavior: levels should come from real breed attributes such as
   `exerciseNeeds`, `trainability`, `sheddingLevel`, `groomingNeeds`,
   `goodWithChildren`, `maintenanceCost` and `aloneTolerance`.

2. Decide what to show for fields that are not yet canonical attributes.
   Examples: `healthOfBreed` and `intelligence` exist in Freeads candidates, but
   are not currently first-class canonical engine fields. For beta, either hide
   them or derive/display them only when the backend has a reviewed value.

3. Run a full app smoke after UI changes.
   Minimum flow: Welcome -> Questionnaire -> Result -> Breed Details -> Gallery.

4. Validate live backend output.
   Check that `/match/preview`, `/breeds/{breedId}` and
   `/media/story-avatars/{fileName}` still return the expected data.

## Current Breed Import Algorithm

Use this exact rhythm when catalog work resumes.

1. Choose a curated wave, not random alphabet order.
   Prefer product coverage gaps:
   - one companion/apartment profile
   - one active/sporting or working profile
   - one terrier/hound/spitz/guardian profile

2. Create a phase manifest.
   Example file:
   `docs/backend/import_candidates/freeads_phaseN_manifest.v1.json`

3. Capture source HTML through Safari:

```bash
python3 tool/backend_specs/capture_freeads_html.py \
  --manifest docs/backend/import_candidates/freeads_phaseN_manifest.v1.json \
  --pause-seconds 4 \
  --auto-wait-seconds 5 \
  --final-wait-seconds 3
```

4. Parse captured HTML into raw Freeads snapshots:

```bash
python3 tool/backend_specs/parse_freeads_html.py \
  --manifest docs/backend/import_candidates/freeads_phaseN_manifest.v1.json
```

5. Generate candidates:

```bash
python3 tool/backend_specs/generate_freeads_candidates.py \
  --manifest docs/backend/import_candidates/freeads_phaseN_manifest.v1.json \
  --output-dir docs/backend/import_candidates
```

6. Review candidates before canonical import.
   Treat Freeads as a primary reviewed source, not truth.
   Be especially conservative with:
   - `aloneTolerance`
   - `beginnerFriendly`
   - `goodWithChildren`
   - `goodWithOtherPets`
   - `temperamentCalm`
   - `maintenanceCost`

7. Add reviewed overrides to:
   `tool/backend_specs/generate_freeads_breed_fixtures.py`

8. Create/update the phase import manifest:
   `docs/backend/import_candidates/freeads_phaseN_import_manifest.v1.json`

9. Generate canonical breed fixtures:

```bash
python3 tool/backend_specs/generate_freeads_breed_fixtures.py \
  --manifest docs/backend/import_candidates/freeads_phaseN_import_manifest.v1.json \
  --candidate-dir docs/backend/import_candidates
```

10. Add new breed fixtures to:
    `docs/backend/examples/catalog.v1.json`

11. Regenerate Freeads registry and mapping:

```bash
python3 tool/backend_specs/generate_freeads_registry.py
```

12. Run validation:

```bash
flutter test test/backend_specs/reference_matcher_fixture_test.dart \
  test/backend_specs/examples_json_validation_test.dart

HOME=/private/tmp DART_SUPPRESS_ANALYTICS=true \
  dart run tool/backend_specs/validate_catalog.dart
```

13. If a new breed enters top-3 honestly, update `acceptableTop3`.
    Do not weaken a correct breed profile just to preserve old fixture output.

14. Commit each meaningful import step separately.
    Good commit shapes:
    - `feat(catalog): capture phaseN wave and import <breed>`
    - `feat(catalog): import <breed>`

## Post-Beta Catalog Plan

After beta release, resume catalog expansion in larger but still reviewed waves:

- Target wave size: `10-15` breeds.
- Keep each wave curated by product coverage, not alphabet.
- After each wave, run a short ranking audit.
- Add new ranking fixtures when a new user segment appears.
- Keep cats as a separate workstream.

Recommended post-beta rhythm:

1. One catalog wave.
2. One ranking audit.
3. One UI/content polish pass.
4. Repeat.

## Risks To Watch

- Importing too many breeds before UI is trustworthy.
- Letting similar breeds collapse into the same profile.
- Accepting optimistic Freeads labels without review.
- Growing the catalog faster than ranking fixtures.
- Exposing cat choices before the cat engine and data are ready.

## Next Best Step

Switch from catalog expansion to beta UI readiness.

The first implementation target should be:

`CharacteristicsSection` becomes data-driven from real canonical breed
attributes, with a fallback for missing optional traits.
