// =============================================================================
// AD SERVICE (Rewarded Ad Simulation)
// =============================================================================

import 'dart:async';

/// Manages rewarded ad simulation.
/// In production, replace with google_mobile_ads / AdMob integration.
class AdService {
  static final AdService _instance = AdService._();
  static AdService get instance => _instance;
  AdService._();

  bool _adsRemoved = false;

  /// Whether ads should be shown (false if user purchased ad removal)
  bool get adsEnabled => !_adsRemoved;
  set adsRemoved(bool value) => _adsRemoved = value;

  // ====================================================================
  // REWARDED AD: Extra Moves on Level Fail
  // ====================================================================

  /// Shows a simulated rewarded ad for extra moves.
  /// Returns true if the ad was "watched" successfully.
  Future<bool> showRewardedAdForMoves() async {
    if (_adsRemoved) {
      return true;
    }

    return await _showAdOverlay(
      title: 'Watch Ad for +5 Moves',
      rewardDescription: '+5 moves to continue!',
      duration: 3,
    );
  }

  /// Shows a simulated rewarded ad for extra life.
  Future<bool> showRewardedAdForLife() async {
    if (_adsRemoved) return true;

    return await _showAdOverlay(
      title: 'Watch Ad for +1 Life',
      rewardDescription: '+1 life restored!',
      duration: 3,
    );
  }

  /// Shows a simulated rewarded ad for double daily coins.
  Future<bool> showRewardedAdForDailyBonus() async {
    if (_adsRemoved) return true;

    return await _showAdOverlay(
      title: 'Watch Ad for Double Coins',
      rewardDescription: 'Today\'s coins will be doubled!',
      duration: 3,
    );
  }

  // ====================================================================
  // AD OVERLAY (Simulated)
  // ====================================================================

  Future<bool> _showAdOverlay({
    required String title,
    required String rewardDescription,
    required int duration,
  }) async {
    // Note: BuildContext is passed by caller when integrating with UI.
    // This stub simulates ad completion without requiring a context.
    await Future.delayed(Duration(seconds: duration));
    return true;
  }
}