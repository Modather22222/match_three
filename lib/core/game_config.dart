// =============================================================================
// LEVEL CONFIGURATION
// =============================================================================

import 'package:flutter_game/models/level_model.dart';

/// Returns the configuration for a given level number.
/// Levels are 1-indexed.
LevelConfig getLevelConfig(int level) {
  // Clamp level to valid range
  final lvl = level.clamp(1, 50);

  // Target score: 300 + (level - 1) * 200
  // Level 1: 300, Level 2: 500, Level 3: 700, ... Level 15: 3100
  final targetScore = 300 + (lvl - 1) * 200;

  // Max moves: starts at 30, decreases by 1 per level, minimum 15
  // Level 1: 30, Level 2: 29, ... Level 16: 15, Level 17+: 15
  final maxMoves = (30 - (lvl - 1)).clamp(15, 30);

  // Number of tile types: 4 for levels 1-2, 5 for level 3+
  final numTileTypes = lvl <= 2 ? 4 : 5;

  return LevelConfig(
    levelNumber: lvl,
    targetScore: targetScore,
    maxMoves: maxMoves,
    numTileTypes: numTileTypes,
  );
}

/// Difficulty label for UI display
String getDifficultyLabel(int level) {
  if (level <= 1) return 'Tutorial';
  if (level <= 2) return 'Easy';
  if (level <= 4) return 'Medium';
  if (level <= 5) return 'Medium-Hard';
  if (level <= 9) return 'Hard';
  if (level <= 14) return 'Very Hard';
  return 'Expert';
}