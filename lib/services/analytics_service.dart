// =============================================================================
// ANALYTICS SERVICE
// =============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';

/// Tracks game events for analytics.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  static AnalyticsService get instance => _instance;
  AnalyticsService._();

  final List<Map<String, dynamic>> _pendingEvents = [];
  bool _online = true;

  void logEvent(String eventType, {Map<String, dynamic>? parameters}) {
    final event = {
      'event_type': eventType,
      'event_data': parameters ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };
    _pendingEvents.add(event);
    if (_online) _flushEvents();
  }

  void levelStart(int levelNumber) {
    logEvent('level_start', parameters: {'level_number': levelNumber});
  }

  void levelComplete(int levelNumber, int stars, int score, int movesLeft) {
    logEvent('level_complete', parameters: {
      'level_number': levelNumber,
      'stars': stars,
      'score': score,
      'moves_left': movesLeft,
    });
  }

  void levelFail(int levelNumber, int score, int target) {
    logEvent('level_fail', parameters: {
      'level_number': levelNumber,
      'score': score,
      'target': target,
    });
  }

  void adWatched(String adType, String rewardType) {
    logEvent('ad_watched', parameters: {'ad_type': adType, 'reward_type': rewardType});
  }

  void iapPurchase(String productId, double price) {
    logEvent('iap_purchase', parameters: {'product_id': productId, 'price': price});
  }

  void powerUpUsed(String powerType, int levelNumber) {
    logEvent('power_up_used', parameters: {
      'power_type': powerType,
      'level_number': levelNumber,
    });
  }

  void sessionStart() => logEvent('session_start');
  void sessionEnd(double durationMinutes) {
    logEvent('session_end', parameters: {'duration': durationMinutes.toStringAsFixed(1)});
  }

  Future<void> _flushEvents() async {
    if (_pendingEvents.isEmpty) return;
    try {
      final events = List<Map<String, dynamic>>.from(_pendingEvents);
      await Supabase.instance.client.from('analytics').insert(
        events.map((e) => {
          'event_type': e['event_type'],
          'event_data': e['event_data'],
          'created_at': e['timestamp'],
        }).toList(),
      );
      _pendingEvents.clear();
    } catch (_) {
      _online = false;
    }
  }

  void setOnline(bool online) {
    _online = online;
    if (online) _flushEvents();
  }
}