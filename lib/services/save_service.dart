// =============================================================================
// SAVE SERVICE
// =============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
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

  // Debounce flag: prevents multiple rapid Hive writes
  bool _savePending = false;

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
    _scheduleSave();
  }

  int get lives => _data.lives;
  set lives(int v) {
    _data.lives = v.clamp(0, 5);
    _scheduleSave();
  }

  double get lastLifeTime => _data.lastLifeTime;
  set lastLifeTime(double v) {
    _data.lastLifeTime = v;
    _scheduleSave();
  }

  int get coins => _data.coins;
  set coins(int v) {
    _data.coins = v.clamp(0, 999999);
    _scheduleSave();
  }

  bool get soundEnabled => _data.soundEnabled;
  set soundEnabled(bool v) {
    _data.soundEnabled = v;
    _scheduleSave();
  }

  int get powerHammer => _data.powerHammer;
  set powerHammer(int v) {
    _data.powerHammer = v.clamp(0, 99);
    _scheduleSave();
  }

  int get powerShuffle => _data.powerShuffle;
  set powerShuffle(int v) {
    _data.powerShuffle = v.clamp(0, 99);
    _scheduleSave();
  }

  int get powerMoves => _data.powerMoves;
  set powerMoves(int v) {
    _data.powerMoves = v.clamp(0, 99);
    _scheduleSave();
  }

  bool get adsRemoved => _data.adsRemoved;
  set adsRemoved(bool v) {
    _data.adsRemoved = v;
    _scheduleSave();
  }

  bool get starterSeen => _data.starterSeen;
  set starterSeen(bool v) {
    _data.starterSeen = v;
    _scheduleSave();
  }

  String get lastDaily => _data.lastDaily;
  set lastDaily(String v) {
    _data.lastDaily = v;
    _scheduleSave();
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
      _scheduleSave();
    }
  }

  bool spendCoins(int amount) {
    if (_data.coins < amount) return false;
    _data.coins -= amount;
    _scheduleSave();
    return true;
  }

  void earnCoins(int amount) {
    _data.coins += amount;
    _scheduleSave();
  }

  void addLives(int count) {
    _data.lives = (_data.lives + count).clamp(0, 5);
    _data.lastLifeTime = DateTime.now().millisecondsSinceEpoch / 1000;
    _scheduleSave();
  }

  void consumeLife() {
    if (_data.lives > 0) {
      _data.lives--;
      if (_data.lives == 0) {
        _data.lastLifeTime = DateTime.now().millisecondsSinceEpoch / 1000;
      }
      _scheduleSave();
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
    try {
      final json = _box.get(_keySave);
      if (json is Map) {
        _data = SaveData.fromJson(Map<String, dynamic>.from(json));
      } else {
        _data = SaveData.defaults();
      }
    } catch (e) {
      if (kDebugMode) print('SaveService load error: $e');
      _data = SaveData.defaults();
    }
    regenLives();
  }

  /// Schedules a debounced save to disk. Multiple rapid calls only write once.
  void _scheduleSave() {
    if (_savePending) return;
    _savePending = true;
    scheduleMicrotask(_flushSave);
  }

  Future<void> _flushSave() async {
    _savePending = false;
    try {
      await _box.put(_keySave, _data.toJson());
    } catch (e) {
      if (kDebugMode) print('SaveService flush error: $e');
    }
  }

  /// Force an immediate save (for critical moments like app pause)
  Future<void> flushNow() async {
    _savePending = false;
    try {
      await _box.put(_keySave, _data.toJson());
    } catch (e) {
      if (kDebugMode) print('SaveService force save error: $e');
    }
  }

  void resetToDefaults() {
    _data = SaveData.defaults();
    _scheduleSave();
  }
}