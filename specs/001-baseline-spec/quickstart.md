# Quickstart: Baseline Match-Three Game Planning

## What this feature delivers

This baseline feature delivers the planning artifacts needed for the current match-three Flutter game repository: a validated implementation plan, research report, data model, quickstart guidance, and persistence contract.

## Files to review

- `specs/001-baseline-spec/spec.md`
- `specs/001-baseline-spec/plan.md`
- `specs/001-baseline-spec/research.md`
- `specs/001-baseline-spec/data-model.md`
- `specs/001-baseline-spec/contracts/save-schema.md`
- `specs/001-baseline-spec/checklists/requirements.md`

## How to use this baseline

1. Read the baseline specification in `specs/001-baseline-spec/spec.md`.
2. Confirm the implementation plan in `specs/001-baseline-spec/plan.md` aligns with the existing repo architecture.
3. Review the data model and persistence contract to verify the core game entities and save schema.
4. Use this feature directory as the input to `/speckit.tasks` after planning is complete.

## Development commands

- Install dependencies:
  - `flutter pub get`
- Run the app on a connected device:
  - `flutter run`
- Execute unit tests:
  - `flutter test`

## Next step

Generate task-level implementation work by running `/speckit.tasks` once the plan and design artifacts are confirmed.
