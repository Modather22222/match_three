// =============================================================================
// SUPABASE CLOUD SAVE SERVICE
// =============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_game/services/save_service.dart';
import 'package:flutter_game/models/save_data.dart';

/// Handles cloud save operations via Supabase.
class SupabaseCloudSave {
  static final SupabaseCloudSave _instance = SupabaseCloudSave._();
  static SupabaseCloudSave get instance => _instance;
  SupabaseCloudSave._();

  SupabaseClient get _client => Supabase.instance.client;

  /// Upload local save data to Supabase cloud.
  Future<bool> uploadSave(SaveService saveService, String userId) async {
    try {
      final data = saveService.data.toJson();
      await _client.from('profiles').update({
        'coins': data['coins'],
        'levels_completed': _computeLevelsCompleted(data),
        'total_score': data['currentLevel'] * 100,
        'sound_enabled': data['soundEnabled'],
        'ads_removed': data['adsRemoved'],
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Download cloud save data from Supabase.
  Future<SaveData?> downloadSave(String userId) async {
    try {
      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final saveService = SaveService();
      await saveService.init();
      saveService.coins = profile['coins'] as int? ?? 500;
      saveService.soundEnabled = profile['sound_enabled'] as bool? ?? true;
      saveService.adsRemoved = profile['ads_removed'] as bool? ?? false;
      saveService.starterSeen = true;

      // Sync level progress
      final progress = await _client
          .from('level_progress')
          .select()
          .eq('player_id', userId)
          .order('level_number');

      for (final row in progress) {
        final levelNum = row['level_number'] as int;
        saveService.setLevelRecord(
          levelNum,
          row['best_stars'] as int? ?? 0,
          row['best_score'] as int? ?? 0,
        );
      }

      return saveService.data;
    } catch (e) {
      return null;
    }
  }

  /// Sync entire level progress to cloud.
  Future<void> syncLevelProgress(String userId, SaveService saveService) async {
    for (final entry in saveService.data.levels.entries) {
      final levelNum = entry.key;
      final record = entry.value;
      await _client.from('level_progress').upsert({
        'player_id': userId,
        'level_number': levelNum,
        'best_score': record.score,
        'best_stars': record.stars,
      });
    }
  }

  /// Sync shop purchases to cloud.
  Future<void> syncPurchases(String userId, String productId, int priceCents) async {
    await _client.from('purchases').insert({
      'player_id': userId,
      'product_id': productId,
      'product_name': productId,
      'price_cents': priceCents,
    });
  }

  int _computeLevelsCompleted(Map<String, dynamic> data) {
    if (data['levels'] is! Map) return 0;
    int count = 0;
    for (final entry in (data['levels'] as Map).entries) {
      if (entry.value != null && (entry.value['stars'] as int? ?? 0) > 0) {
        count++;
      }
    }
    return count;
  }
}