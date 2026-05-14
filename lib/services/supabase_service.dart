// =============================================================================
// SUPABASE SERVICE
// =============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';

/// Central service for all Supabase operations.
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  // ====================================================================
  // AUTH
  // ====================================================================

  Future<AuthResponse> signInAnonymously() async {
    return await client.auth.signInAnonymously();
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmail(
      String email, String password, String? displayName) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'display_name': displayName} : null,
    );
  }

  Future<void> signOut() async => await client.auth.signOut();

  String? get currentUserId => client.auth.currentUser?.id;
  bool get isSignedIn =>
      client.auth.currentUser != null && !client.auth.currentUser!.isAnonymous;

  // ====================================================================
  // PLAYER PROFILE
  // ====================================================================

  Future<Map<String, dynamic>?> getPlayerProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return response;
  }

  Future<void> createPlayerProfile(String userId, String displayName) async {
    await client.from('profiles').insert({
      'id': userId,
      'display_name': displayName,
      'total_score': 0,
      'high_score': 0,
      'levels_completed': 0,
      'coins': 500,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updatePlayerProfile(String userId, Map<String, dynamic> updates) async {
    await client.from('profiles').update(updates).eq('id', userId);
  }

  // ====================================================================
  // LEVEL PROGRESS
  // ====================================================================

  Future<List<Map<String, dynamic>>> getLevelProgress(String userId) async {
    final response = await client
        .from('level_progress')
        .select()
        .eq('player_id', userId)
        .order('level_number');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> saveLevelProgress({
    required String userId,
    required int levelNumber,
    required int stars,
    required int score,
    required int movesLeft,
  }) async {
    final existing = await client
        .from('level_progress')
        .select()
        .eq('player_id', userId)
        .eq('level_number', levelNumber)
        .maybeSingle();

    if (existing != null) {
      final bestScore = existing['best_score'] as int? ?? 0;
      final bestStars = existing['best_stars'] as int? ?? 0;
      if (score > bestScore || stars > bestStars) {
        await client.from('level_progress').update({
          'best_score': score > bestScore ? score : bestScore,
          'best_stars': stars > bestStars ? stars : bestStars,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', existing['id']);
      }
    } else {
      await client.from('level_progress').insert({
        'player_id': userId,
        'level_number': levelNumber,
        'best_score': score,
        'best_stars': stars,
        'moves_left': movesLeft,
      });
    }
  }

  // ====================================================================
  // LEADERBOARD
  // ====================================================================

  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    final response = await client
        .from('profiles')
        .select('id, display_name, high_score')
        .order('high_score', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  // ====================================================================
  // COIN BALANCE
  // ====================================================================

  Future<int> getCoinBalance(String userId) async {
    final profile = await getPlayerProfile(userId);
    return profile?['coins'] as int? ?? 500;
  }

  Future<void> updateCoinBalance(String userId, int newBalance) async {
    await client
        .from('profiles')
        .update({
          'coins': newBalance,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  // ====================================================================
  // DATABASE SETUP (run once in Supabase SQL Editor)
  // ====================================================================

  /// SQL schema to run in Supabase SQL Editor for initial setup.
  static const setupSQL = '''
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

    CREATE TABLE IF NOT EXISTS profiles (
      id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
      display_name TEXT NOT NULL DEFAULT 'Player',
      email TEXT,
      coins INT DEFAULT 500,
      total_score INT DEFAULT 0,
      high_score INT DEFAULT 0,
      levels_completed INT DEFAULT 0,
      sound_enabled BOOLEAN DEFAULT true,
      ads_removed BOOLEAN DEFAULT false,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS level_progress (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      player_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
      level_number INT NOT NULL,
      best_score INT DEFAULT 0,
      best_stars INT DEFAULT 0,
      moves_left INT DEFAULT 0,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW(),
      UNIQUE(player_id, level_number)
    );

    CREATE TABLE IF NOT EXISTS purchases (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      player_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
      product_id TEXT NOT NULL,
      product_name TEXT NOT NULL,
      price_cents INT NOT NULL,
      currency TEXT DEFAULT 'USD',
      purchased_at TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS analytics (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      player_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
      event_type TEXT NOT NULL,
      event_data JSONB DEFAULT '{}',
      created_at TIMESTAMPTZ DEFAULT NOW()
    );

    ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
    ALTER TABLE level_progress ENABLE ROW LEVEL SECURITY;
    ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
    ALTER TABLE analytics ENABLE ROW LEVEL SECURITY;

    CREATE POLICY "Owners can view own profile" ON profiles
      FOR SELECT USING (auth.uid() = id);
    CREATE POLICY "Owners can update own profile" ON profiles
      FOR UPDATE USING (auth.uid() = id);
    CREATE POLICY "Owners can insert own progress" ON level_progress
      FOR INSERT WITH CHECK (auth.uid() = player_id);
    CREATE POLICY "Owners can view own progress" ON level_progress
      FOR SELECT USING (auth.uid() = player_id);
    CREATE POLICY "Owners can update own progress" ON level_progress
      FOR UPDATE USING (auth.uid() = player_id);
    CREATE POLICY "Authenticated can insert analytics" ON analytics
      FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
  ''';
}