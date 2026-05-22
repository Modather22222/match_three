# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A casual Match-3 tile puzzle game built with Flutter and the Flame game engine. Players swap adjacent tiles to create lines of 3+ matching tiles, completing levels by reaching score targets within limited moves. Features special tiles, power-ups, a coin economy, and monetization stubs.

- **Language:** Dart (SDK ^3.10.8)
- **Framework:** Flutter 3.x + Flame ^1.22.0
- **State Management:** Riverpod ^2.6.1
- **Persistence:** Hive ^2.2.3
- **Backend:** Supabase (placeholder credentials in `main.dart`)
- **Target:** Android (primary), iOS (secondary), portrait-only, 720x1280 logical pixels

## Common Commands

```bash
# Run on connected device/emulator
flutter run

# Run on web (dev container)
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080

# Build
flutter build apk          # Android APK
flutter build ios          # iOS

# Analyze (lint)
flutter analyze

# Test
flutter test               # Note: no test files exist yet

# Code generation (Hive type adapters)
dart run build_runner build
```

## Architecture

The codebase follows a strict 4-layer architecture with a one-way dependency flow:

```
Screens (Flutter widgets)
    ↓
Game (Flame components)
    ↓
Engine (Pure Dart — no Flutter/Flame imports)
    ↓
Models (plain data classes)
```

### Layer Details

**`lib/engine/`** — Pure Dart game logic with zero Flutter/Flame dependencies. Uses a custom `Vec2` class (`core/vector2d.dart`) instead of Flame's `Vector2`. This layer is independently testable.
- `board.dart` — Grid state, swap logic, board generation (avoids initial matches)
- `match_finder.dart` — Horizontal/vertical run detection; classifies L/T shapes as Wrapped, 5+ as Bomb, 4 as Striped
- `cascade_processor.dart` — Clear → gravity → refill loop (max 25 depth) with combo scoring
- `special_tile_logic.dart` — Special tile effects, combos, recursive chain expansion (max depth 40)
- `input_handler.dart` — Tap-tap and swipe input with selection state

**`lib/game/`** — Flame components that render the engine state. `MatchGame` (in `match_game.dart`) is the main `FlameGame` class that orchestrates everything.
- All visuals are procedurally rendered (no image assets) — tiles are styled rounded rectangles with symbols
- Components: `tile_component.dart`, `board_component.dart`, `background_component.dart`, `score_popup_component.dart`, `particle_component.dart`

**`lib/screens/`** — Flutter screen widgets wired to Flame via `GameWidget`. Routes: `/` (main menu), `/level-select`, `/game` (takes level int argument), `/shop`, `/settings`.

**`lib/providers/`** — Riverpod `StateNotifier` providers for game state, save data, settings, and shop.

**`lib/services/`** — All currently stub implementations that log to console:
- `save_service.dart` — Hive-based persistence with debounced writes (key: `match3_data`, box: `match3_save`)
- `audio_service.dart`, `ad_service.dart`, `purchase_service.dart`, `notification_service.dart` — stubs
- `supabase_service.dart` — Contains SQL schema for future tables
- **Note:** There is a duplicate `save_provider.dart` in both `lib/services/` and `lib/providers/` (identical content)

**`lib/core/`** — Constants (`constants.dart` has board dimensions, tile sizes, animation timings, color hex values), extensions, `Vec2` class, and game config.

**`lib/models/`** — Data models: `tile_model.dart`, `level_model.dart`, `save_data.dart`, `shop_item.dart`, `level_record.dart`

### Navigation

Named routes via `AppRouter.generateRoute` in `lib/app_router.dart` with 500ms fade transitions.

### Key Constants

- Board: 8x8 grid, 76px tiles, origin at (68, 240)
- Tile types: 4 for tutorial levels 1-2, 5 for level 3+
- Match thresholds: min 3, striped 4, bomb 5
- Max lives: 5, regeneration: 20 minutes
- Max levels: 50
- Max cascade depth: 25

## Current Status

Per `PROGRESS.md`: Phase 0 (Foundation) and Phase 1 (Engine) and Phase 2 (Flame Visual Layer) are complete. No tests exist. No assets directory exists (game is fully procedural). Supabase credentials are placeholders.
