// =============================================================================
// SHOP PROVIDER (Reactive)
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_game/services/save_service.dart';

class ShopNotifier extends StateNotifier<Map<String, int>> {
  ShopNotifier()
      : super({
          'hammer': 3,
          'shuffle': 2,
          'extra_moves': 1,
        });

  void loadFromSave(SaveService saveService) {
    state = {
      'hammer': saveService.powerHammer,
      'shuffle': saveService.powerShuffle,
      'extra_moves': saveService.powerMoves,
    };
  }

  int stock(String itemId) => state[itemId] ?? 0;

  void consume(String itemId) {
    final current = stock(itemId);
    if (current > 0) {
      state = {...state, itemId: current - 1};
    }
  }

  void addStock(String itemId, int amount) {
    final current = stock(itemId);
    state = {...state, itemId: current + amount};
  }

  void setStock(String itemId, int amount) {
    state = {...state, itemId: amount};
  }
}

final shopProvider =
    StateNotifierProvider<ShopNotifier, Map<String, int>>((ref) {
  return ShopNotifier();
});