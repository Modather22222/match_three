# Data Model: Baseline Match-Three Game Feature

## Core Entities

### TileModel
Represents a single board tile.

- `int tileType` — tile color/type index (0..4)
- `int col` — grid column index
- `int row` — grid row index
- `SpecialType specialType` — NONE, STRIPED_H, STRIPED_V, WRAPPED, COLOR_BOMB
- `bool isSelected` — whether the tile is currently selected
- `bool isClearing` — whether the tile is part of a clearing animation

### LevelConfig
Defines static level parameters.

- `int levelNumber`
- `int targetScore`
- `int moves`
- `int tileTypes` — number of active tile colors
- `bool allowSpecials` — whether special tile creation is enabled
- `int starThreshold1`
- `int starThreshold2`
- `int starThreshold3`

### SaveData
Persisted player state and progression.

- `int version` — schema version for migration
- `int currentLevel`
- `Map<int, LevelRecord> levels`
- `int coins`
- `int lives`
- `int powerHammer`
- `int powerShuffle`
- `int powerMoves`
- `String lastDaily`
- `int lastLifeTime`
- `bool soundEnabled`
- `bool adsRemoved`
- `bool starterSeen`

### LevelRecord
Tracks best results for each level.

- `int stars` — 0..3
- `int score`

### MatchInfo
Describes the result of a board scan.

- `List<Vector2> clearPositions`
- `Map<Vector2, SpecialType> specials`
- `int comboMultiplier`

## Relationships

- `SaveData` contains a `levels` map keyed by `levelNumber` and referencing `LevelRecord`.
- `LevelConfig` is referenced by the game flow and is not directly persisted.
- `TileModel` is used in `BoardState` and by game UI components.
- `MatchInfo` is a transient entity produced by match detection and consumed by cascade resolution.

## Validation Rules

- `tileType` must be within the active range for the current level.
- `SpecialType` must be valid for the current tile and match outcome.
- `moves` and `coins` must be non-negative.
- `stars` must be an integer between 0 and 3.
- `SaveData.version` must increment when fields are added or changed.
- Missing persisted fields must default safely during load.

## State Transitions

### Game flow states

- `loading` → `ready`
- `ready` → `selected` → `swapping`
- `swapping` → `matched` / `invalid`
- `matched` → `clearing` → `gravity` → `refill` → `ready` or `win` / `lose`
- `win` / `lose` → `popup`

### Persistence updates

- Save after level completion, coin changes, lives updates, power-up changes, and settings toggles.
- Guard against partial saves by writing full `SaveData` snapshots.
