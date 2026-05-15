<!--
Sync Impact Report
Version change: template -> 1.0.0
Modified principles: placeholder -> I. Gameplay Clarity, II. Pure Engine Logic, III. Reliable Persistence, IV. Consistent Mobile UX, V. Player-Friendly Monetization
Added sections: Technology Constraints, Development Workflow
Removed sections: none
Templates requiring updates: .specify/templates/plan-template.md (✅ reviewed), .specify/templates/spec-template.md (✅ reviewed), .specify/templates/tasks-template.md (✅ reviewed)
Follow-up TODOs: none
-->

# Match-Three Tile Puzzle Game Constitution

## Core Principles

### I. Gameplay Clarity
MUST deliver a simple, polished match-3 core loop with predictable swaps, immediate feedback, and balanced progression. New gameplay mechanics MUST be added only when they strengthen the core match-swap-cascade experience and reduce player confusion.

### II. Pure Engine Logic
MUST keep board generation, match detection, cascade resolution, special tile effects, scoring, and level progression in pure Dart with no Flutter or Flame dependencies. Engine code MUST remain independently testable and reusable across UI ports.

### III. Reliable Persistence
MUST persist player state, lives, coins, level records, daily rewards, power-up inventory, settings, and monetization flags. Save schema changes MUST be versioned and forward-compatible so missing fields default safely.

### IV. Consistent Mobile UX
MUST prioritize portrait mobile presentation, responsive input handling, coherent animations, and clear game-state feedback. Input MUST be blocked while cascades or popups are active, and game state MUST recover cleanly across app lifecycle transitions.

### V. Player-Friendly Monetization
MUST make monetization transparent, optional, and supportive of play. The economy MUST reward gameplay, preserve earned coins on failed attempts, and avoid pay-to-win dependencies for the core experience.

## Technology Constraints
Use Flutter + Flame for the app/UI layer, with Provider- or Riverpod-style state management and SharedPreferences or Hive persistence. Target Android API 24+ and iOS 14+. Lock orientation to portrait. The engine layer MUST be pure Dart and must not import Flutter/Flame. Performance goals include 60fps and stable behavior on low-memory devices.

## Development Workflow
Every pull request MUST reference this constitution and include a short compliance summary. New gameplay, engine, save schema, or monetization changes MUST include focused tests for the affected logic. Significant changes MUST also include documentation updates in README or game design notes.

## Governance
This constitution is authoritative for architecture, quality, and product decisions in this match-three game. Amendments require a documented PR with the affected section, rationale, impact assessment, and a version-bump recommendation.

Versioning policy:
- MAJOR when principles or governance sections are removed or redefined
- MINOR when new principles, workflow constraints, or material development guidance are added
- PATCH for wording clarifications, alignment updates, or editorial refinement

All PRs MUST verify constitution compliance during review. Major gameplay or persistence changes MUST include regression tests and a risk summary.

**Version**: 1.0.0 | **Ratified**: 2026-05-15 | **Last Amended**: 2026-05-15
