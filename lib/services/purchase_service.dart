// =============================================================================
// PURCHASE SERVICE
// =============================================================================

import 'package:flutter_game/services/save_service.dart';

/// Handles in-game purchases using coins or IAP.
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._();
  static PurchaseService get instance => _instance;
  PurchaseService._();

  SaveService get saveService => _saveService;
  final SaveService _saveService = SaveService();

  /// Purchase a power-up with coins. Returns true if successful.
  bool buyPowerUp(String itemId, int coinCost) {
    if (!_saveService.spendCoins(coinCost)) return false;

    switch (itemId) {
      case 'hammer':
        _saveService.powerHammer += 1;
        break;
      case 'shuffle':
        _saveService.powerShuffle += 1;
        break;
      case 'extra_moves':
        _saveService.powerMoves += 1;
        break;
    }

    return true;
  }

  /// Purchase coins with real money (IAP placeholder).
  Future<bool> buyCoins(String productId, int coinAmount) async {
    // TODO: Integrate with actual IAP (google_play_in_app_purchases)
    _saveService.earnCoins(coinAmount);
    return true;
  }

  /// Remove ads permanently (IAP placeholder).
  Future<bool> removeAds() async {
    // TODO: Integrate with actual IAP
    _saveService.adsRemoved = true;
    return true;
  }

  /// Purchase starter pack.
  Future<bool> buyStarterPack() async {
    _saveService.coins += 5000;
    _saveService.powerHammer += 5;
    _saveService.powerShuffle += 5;
    _saveService.powerMoves += 5;
    _saveService.starterSeen = true;
    return true;
  }

  /// Check if player can afford a purchase.
  bool canAfford(int coinCost) {
    return _saveService.coins >= coinCost;
  }
}