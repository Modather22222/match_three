// =============================================================================
// SHOP ITEM MODEL
// =============================================================================

/// Defines a purchasable item in the shop.
class ShopItem {
  final String id;
  final String name;
  final String description;
  final int coinCost; // 0 if IAP (real money)
  final String? productId; // IAP product ID (for real purchases)
  final String icon; // emoji or asset reference
  final bool isConsumable;
  final bool isPremium; // ad removal / starter pack

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    this.coinCost = 0,
    this.productId,
    this.icon = '❓',
    this.isConsumable = true,
    this.isPremium = false,
  });

  bool get isIAP => productId != null;
  bool get isCoinItem => !isIAP && coinCost > 0;
}

// ---- Predefined Shop Items ----

class ShopItems {
  // Power-ups (coin purchases)
  static const hammer = ShopItem(
    id: 'hammer',
    name: 'Hammer',
    description: 'Destroys one tile on the board.',
    coinCost: 50,
    icon: '🔨',
    isConsumable: true,
  );

  static const shuffle = ShopItem(
    id: 'shuffle',
    name: 'Shuffle',
    description: 'Shuffles all tiles randomly.',
    coinCost: 30,
    icon: '🔀',
    isConsumable: true,
  );

  static const extraMoves = ShopItem(
    id: 'extra_moves',
    name: 'Extra Moves',
    description: 'Adds 5 extra moves.',
    coinCost: 40,
    icon: '⏱',
    isConsumable: true,
  );

  // Coin packs (simulated IAP)
  static const coins1000 = ShopItem(
    id: 'coins_1000',
    name: '1,000 Coins',
    description: '1,000 coins to spend in-game.',
    productId: 'coins_1000',
    icon: '💰',
    isConsumable: true,
  );

  static const coins3000 = ShopItem(
    id: 'coins_3000',
    name: '3,000 Coins',
    description: 'Best value! 3,000 coins.',
    productId: 'coins_3000',
    icon: '💰✨',
    isConsumable: true,
  );

  static const coins10000 = ShopItem(
    id: 'coins_10000',
    name: '10,000 Coins',
    description: '10,000 coins for dedicated players.',
    productId: 'coins_10000',
    icon: '💰💰',
    isConsumable: true,
  );

  // Premium (one-time)
  static const removeAds = ShopItem(
    id: 'remove_ads',
    name: 'Remove Ads',
    description: 'Permanently removes all ads.',
    productId: 'remove_ads',
    icon: '🚫',
    isConsumable: false,
    isPremium: true,
  );

  static const starterPack = ShopItem(
    id: 'starter_pack',
    name: 'Starter Pack',
    description: '5,000 coins + 5× each power-up.',
    productId: 'starter_pack',
    icon: '🎁',
    isConsumable: false,
    isPremium: false,
  );

  // Bundles for shop sections
  static List<ShopItem> get powerUpItems => [hammer, shuffle, extraMoves];
  static List<ShopItem> get coinPackItems =>
      [coins1000, coins3000, coins10000];

  static List<ShopItem> get premiumItems => [removeAds];
  static List<ShopItem> get all => [
        ...powerUpItems,
        ...coinPackItems,
        ...premiumItems,
        starterPack,
      ];

  static ShopItem? byId(String id) {
    try {
      return all.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}