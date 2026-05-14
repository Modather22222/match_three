// =============================================================================
// LEVEL MODEL
// =============================================================================

/// Configuration data for a single level.
/// Created by [getLevelConfig] in game_config.dart.
class LevelConfig {
  final int levelNumber;
  final int targetScore;
  final int maxMoves;
  final int numTileTypes; // 4 or 5

  const LevelConfig({
    required this.levelNumber,
    required this.targetScore,
    required this.maxMoves,
    required this.numTileTypes,
  });

  @override
  String toString() =>
      'LevelConfig(level:$levelNumber, target:$targetScore, moves:$maxMoves, types:$numTileTypes)';
}