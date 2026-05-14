// =============================================================================
// SAVE DATA MODEL
// =============================================================================

import 'package:flutter_game/models/level_record.dart';

/// Serializable save state for the entire game.
/// Stored as a single JSON blob under key "match3_save".
class SaveData {
  int version;
  int currentLevel;
  Map<int, LevelRecord> levels;
  int lives;
  double lastLifeTime;
  String lastDaily;
  bool soundEnabled;
  int coins;
  int powerHammer;
  int powerShuffle;
  int powerMoves;
  bool adsRemoved;
  bool starterSeen;

  SaveData({
    this.version = 2,
    this.currentLevel = 1,
    Map<int, LevelRecord>? levels,
    this.lives = 5,
    this.lastLifeTime = 0,
    this.lastDaily = '',
    this.soundEnabled = true,
    this.coins = 500,
    this.powerHammer = 3,
    this.powerShuffle = 2,
    this.powerMoves = 1,
    this.adsRemoved = false,
    this.starterSeen = false,
  }) : levels = levels ?? {};

  factory SaveData.defaults() => SaveData(
        version: 2,
        currentLevel: 1,
        lives: 5,
        lastLifeTime: DateTime.now().millisecondsSinceEpoch / 1000,
        lastDaily: '',
        soundEnabled: true,
        coins: 500,
        powerHammer: 3,
        powerShuffle: 2,
        powerMoves: 1,
        adsRemoved: false,
        starterSeen: false,
      );

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'currentLevel': currentLevel,
      'levels': {
        for (final entry in levels.entries)
          entry.key.toString(): entry.value.toJson(),
      },
      'lives': lives,
      'lastLifeTime': lastLifeTime,
      'lastDaily': lastDaily,
      'soundEnabled': soundEnabled,
      'coins': coins,
      'powerHammer': powerHammer,
      'powerShuffle': powerShuffle,
      'powerMoves': powerMoves,
      'adsRemoved': adsRemoved,
      'starterSeen': starterSeen,
    };
  }

  factory SaveData.fromJson(Map<String, dynamic> json) {
    final levelsMap = <int, LevelRecord>{};
    if (json['levels'] is Map) {
      for (final entry in (json['levels'] as Map).entries) {
        levelsMap[int.parse(entry.key)] =
            LevelRecord.fromJson(Map<String, dynamic>.from(entry.value));
      }
    }
    return SaveData(
      version: json['version'] as int? ?? 1,
      currentLevel: json['currentLevel'] as int? ?? 1,
      levels: levelsMap,
      lives: json['lives'] as int? ?? 5,
      lastLifeTime: (json['lastLifeTime'] as num?)?.toDouble() ?? 0,
      lastDaily: json['lastDaily'] as String? ?? '',
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      coins: json['coins'] as int? ?? 500,
      powerHammer: json['powerHammer'] as int? ?? 3,
      powerShuffle: json['powerShuffle'] as int? ?? 2,
      powerMoves: json['powerMoves'] as int? ?? 1,
      adsRemoved: json['adsRemoved'] as bool? ?? false,
      starterSeen: json['starterSeen'] as bool? ?? false,
    );
  }
}