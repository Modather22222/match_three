// =============================================================================
// SAVE SERVICE
// =============================================================================

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter_game/models/level_record.dart';
import 'package:flutter_game/models/save_data.dart';

class SaveService {
  static const _boxName = 'match3_save';
  static const _keySave = 'match3_data';

  late Box<dynamic> _box;
  SaveData _data = SaveData.defaults();

  bool get isInitialized => _box.isOpen;

  Future<void> init() async {
    final dir = await path_provider.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    _box = await Hive.openBox(_boxName);
    _loadFromStorage();
  }

  SaveData get data => _data;

  int get currentLevel => _data.currentLevel;
  set currentLevel(int v) {
    _data.currentLevel = v;
    _save();
  }

  int get lives => _data.lives;
  set lives(int v) {
    _data.lives = v.clamp(0, 5);
    _save();
  }

  double get lastLifeTime => _data.lastLifeTime;
  set lastLifeTime(double v) {
    _data.lastLifeTime = v;
    _save();
  }

  int get coins => _data.coins;
  set coins(int v) {
    _data.coins = v.clamp(0, 999999);
    _save();
  }

  bool get soundEnabled => _data.soundEnabled;
  set soundEnabled(bool v) {
    _data.soundEnabled = v;
    _save();
  }

  int get powerHammer => _data.powerHammer;
  set powerHammer(int v) {
    _data.powerHammer = v.clamp(0, 99);
    _save();
  }

  int get powerShuffle => _data.powerShuffle;
  set powerShuffle(int v) {
    _data.powerShuffle = v.clamp(0, 99);
    _save();
  }

  int get powerMoves => _data.powerMoves;
  set powerMoves(int v) {
    _data.powerMoves = v.clamp(0, 99);
    _save();
  }

  bool get adsRemoved => _data.adsRemoved;
  set adsRemoved(bool v) {
    _data.adsRemoved = v;
    _save();
  }

  bool get starterSeen => _data.starterSeen;
  set starterSeen(bool v) {
    _data.starterSeen = v;
    _save();
  }

  String get lastDaily => _data.lastDaily;
  set lastDaily(String v) {
    _data.lastDaily = v;
    _save();
  }

  // Level Records
  Map<String, dynamic> getLevelRecord(int level) {
    final rec = _data.levels[level];
    if (rec == null) return {'stars': 0, 'score': 0};
    return {'stars': rec.stars, 'score': rec.score};
  }

  void setLevelRecord(int level, int stars, int score) {
    final existing = _data.levels[level];
    if (existing == null || score > existing.score) {
      _data.levels[level] = LevelRecord(stars: stars, score: score);
      _save();
    }
  }

  bool spendCoins(int amount) {
    if (_data.coins < amount) return false;
    _data.coins -= amount;
    _save();
    return true;
  }

  void earnCoins(int amount) {
    _data.coins += amount;
    _save();
  }

  void addLives(int count) {
    _data.lives = (_data.lives + count).clamp(0, 5);
    _data.lastLifeTime = DateTime.now().millisecondsSinceEpoch / 1000;
    _save();
  }

  void consumeLife() {
    if (_data.lives > 0) {
      _data.lives--;
      if (_data.lives == 0) {
        _data.lastLifeTime = DateTime.now().millisecondsSinceEpoch / 1000;
      }
      _save();
    }
  }

  int get livesRegenSeconds {
    final elapsed = DateTime.now().millisecondsSinceEpoch / 1000 - _data.lastLifeTime;
    return 1200 - (elapsed % 1200).toInt();
  }

  int get livesRegenCount {
    final elapsed = DateTime.now().millisecondsSinceEpoch / 1000 - _data.lastLifeTime;
    return (elapsed ~/ 1200).clamp(0, 5 - _data.lives);
  }

  void regenLives() {
    final gained = livesRegenCount;
    if (gained > 0) addLives(gained);
  }

  void _loadFromStorage() {
    final json = _box.get(_keySave);
    if (json is Map) {
      _data = SaveData.fromJson(Map<String, dynamic>.from(json));
    } else {
      _data = SaveData.defaults();
    }
    regenLives();
  }

  void _save() {
    _box.put(_keySave, _data.toJson());
  }

  void resetToDefaults() {
    _data = SaveData.defaults();
    _save();
  }
}