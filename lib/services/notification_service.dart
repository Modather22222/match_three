// =============================================================================
// NOTIFICATION SERVICE (Stub)
// =============================================================================

import 'package:flutter/material.dart';

/// Stub for local push notifications.
/// Replace with flutter_local_notifications when added to pubspec.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;
  NotificationService._();

  Future<void> init() async {
    // Initialize notification plugin here when added.
  }

  Future<void> requestPermission() async {
    // Request notification permissions here.
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    debugPrint('[NOTIF] $id: $title - $body');
  }

  Future<void> scheduleDailyRewardReminder() async {
    debugPrint('[NOTIF] Scheduled daily reward reminder');
  }

  Future<void> cancelAll() async {
    debugPrint('[NOTIF] All notifications cancelled');
  }
}