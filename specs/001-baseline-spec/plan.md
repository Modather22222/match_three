# Implementation Plan: Baseline Match-Three Game Feature

**Branch**: `main` | **Date**: 2026-05-15 | **Spec**: `specs/001-baseline-spec/spec.md`

**Input**: Feature specification from `/specs/001-baseline-spec/spec.md`

**Note**: This file defines the baseline implementation plan for the existing Flutter/Flame match-three game repository. It is intentionally scoped to align with the current codebase and prepare the project for task creation.

## Summary

This plan captures the baseline feature definition for the match-three mobile game and documents the project context required to move from specification to execution. It uses the existing Flutter + Flame app architecture and focuses on validating the core game domain, persistence model, and planning artifacts before task generation.

## Technical Context

**Language/Version**: Dart 3.11 / Flutter 3.x

**Primary Dependencies**: Flutter, flame 1.22.0, flutter_riverpod 2.6.1, hive 2.2.3, hive_flutter 1.1.0, path_provider 2.1.5, audioplayers 6.2.1, google_fonts 6.2.1, vector_math 2.1.4, supabase_flutter 2.6.0

**Storage**: Local persistence via Hive; save data is the baseline store and is versioned for forward compatibility. Supabase is present in the repository but not required for this baseline feature.

**Testing**: flutter_test; flutter_lints; Hive type adapter generation via build_runner and hive_generator.

**Target Platform**: Android API 24+, iOS 14+, portrait mobile first, with additional desktop/web platform support available in the repo.

**Project Type**: Mobile app / game

**Performance Goals**: Maintain 60 fps on target devices; keep board updates responsive; preserve stable animation flow for tile swaps, cascades, and special effects.

**Constraints**: Engine logic must remain pure Dart in `lib/engine` and independent of Flutter/Flame. The baseline feature must be responsive on low-memory devices, preserve earned coins on failed attempts, and avoid pay-to-win assumptions.

**Scale/Scope**: Single-player match-three puzzle game with an 8×8 board, special tile effects, level progression, coin economy, lives system, and launch-ready content for approximately 50 levels.

## Constitution Check

- I. Gameplay Clarity: The baseline plan keeps scope focused on the core match-three domain and avoids introducing unrelated systems.
- II. Pure Engine Logic: Existing repository structure separates engine logic from UI, consistent with the constitution requirement.
- III. Reliable Persistence: Baseline design defines a versioned save contract and uses Hive for durable local storage.
- IV. Consistent Mobile UX: Target orientation and interaction flow are mobile-first and supported by existing UI/screen directories.
- V. Player-Friendly Monetization: The baseline scope documents economy and reward mechanics without building new pay-to-win behavior.

**Gate Status**: Pass. No constitution violations were identified for this baseline plan.

## Project Structure

### Documentation (this feature)

```text
specs/001-baseline-spec/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── save-schema.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── app.dart
├── main.dart
├── core/
├── engine/
├── game/
├── models/
├── providers/
├── screens/
├── services/
├── utils/
└── widgets/

assets/
├── images/
├── audio/
└── fonts/

android/
ios/
linux/
macos/
web/
windows/
```

**Structure Decision**: This is a single Flutter mobile-game project. The baseline implementation will extend the existing `lib/engine` pure Dart game logic and preserve the current UI/service layering found under `lib/game`, `lib/screens`, and `lib/services`.

## Complexity Tracking

No constitution violations or added complexity justifications are required for this baseline feature. The plan aligns with the existing codebase and leverages the repo's current architecture.
