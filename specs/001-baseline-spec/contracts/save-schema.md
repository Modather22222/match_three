# Save Schema Contract

## Persistence key

- Hive storage is expected to persist the game save under a stable schema.
- The baseline contract is the `SaveData` structure used by `lib/services/save_service.dart` or equivalent persistence service.

## Contract fields

### SaveData

- `version` (int): save format version
- `currentLevel` (int)
- `levels` (Map<int, LevelRecord>)
- `coins` (int)
- `lives` (int)
- `powerHammer` (int)
- `powerShuffle` (int)
- `powerMoves` (int)
- `lastDaily` (String)
- `lastLifeTime` (int): epoch milliseconds or seconds
- `soundEnabled` (bool)
- `adsRemoved` (bool)
- `starterSeen` (bool)

### LevelRecord

- `stars` (int): 0..3
- `score` (int)

## Migration contract

- When the save schema changes, increment `version` and provide a migration path that fills missing fields with defaults.
- Load logic must tolerate older save data by providing defaults for absent keys.

## Persistence guarantees

- Saved game state must remain consistent across app restarts.
- Coins earned during a failed attempt must be preserved.
- Settings and progression data must survive crashes and lifecycle transitions.
