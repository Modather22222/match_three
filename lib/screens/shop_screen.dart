// =============================================================================
// SHOP SCREEN (Reactive with Purchase Service)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_game/models/shop_item.dart';
import 'package:flutter_game/providers/save_provider.dart';
import 'package:flutter_game/providers/shop_provider.dart';
import 'package:flutter_game/services/purchase_service.dart';
import 'package:flutter_game/services/analytics_service.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  void _handlePurchase(ShopItem item) {
    final purchaseService = PurchaseService.instance;

    if (item.isIAP && item.productId != null) {
      final pid = item.productId!;
      _showPurchaseDialog(item, () async {
        if (pid == 'starter_pack') {
          await purchaseService.buyStarterPack();
        } else {
          await purchaseService.buyCoins(pid, item.coinCost);
        }
        if (mounted) {
          ref.read(saveDataProvider.notifier).reload();
          ref.read(shopProvider.notifier).loadFromSave(purchaseService.saveService);
          AnalyticsService.instance.iapPurchase(pid, item.coinCost.toDouble());
          _showSuccessSnackbar('Purchase successful!');
        }
      });
    } else {
      _showPurchaseDialog(item, () {
        if (purchaseService.buyPowerUp(item.id, item.coinCost)) {
          ref.read(saveDataProvider.notifier).reload();
          ref.read(shopProvider.notifier).loadFromSave(purchaseService.saveService);
          AnalyticsService.instance.logEvent('purchase', parameters: {
            'item': item.id,
            'cost': item.coinCost,
          });
          _showSuccessSnackbar('Purchased ${item.name}!');
        } else {
          _showErrorSnackbar('Not enough coins!');
        }
      });
    }
  }

  void _showPurchaseDialog(ShopItem item, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('CONFIRM PURCHASE', style: TextStyle(color: Color(0xFFF0C040))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 4),
            Text(item.description, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 12),
            Text(
              item.isIAP ? 'Price: \$${item.productId ?? item.id}' : 'Cost: ${item.coinCost} coins',
              style: const TextStyle(color: Color(0xFFF0C040), fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('BUY'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF27AE60),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE74C3C),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coins = ref.watch(saveDataProvider).coins;
    final shopStock = ref.watch(shopProvider);

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF0A0A14)),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'SHOP',
                        style: TextStyle(
                          color: Color(0xFFF0C040),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          const Text('💰', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            '$coins',
                            style: const TextStyle(
                              color: Color(0xFFF0C040),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                ),

                // Inventory section
                _buildInventoryHeader(shopStock),
                const SizedBox(height: 16),
                _buildSectionTitle('Power-ups'),
                _buildPowerUpItems(shopStock),
                const SizedBox(height: 8),
                _buildSectionTitle('Coin Packs'),
                _buildCoinPackItems(),
                const SizedBox(height: 8),
                _buildSectionTitle('Premium'),
                _buildPremiumItems(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryHeader(Map<String, int> shopStock) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0C040), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _invItem('🔨', 'Hammers', shopStock['hammer'] ?? 0),
          _invItem('🔀', 'Shuffles', shopStock['shuffle'] ?? 0),
          _invItem('⏱', 'Extra\nMoves', shopStock['extra_moves'] ?? 0),
        ],
      ),
    );
  }

  Widget _invItem(String icon, String label, int value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          '$value',
          style: const TextStyle(color: Color(0xFFF0C040), fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(color: Color(0xFFF0C040), fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPowerUpItems(Map<String, int> shopStock) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _shopCard(ShopItems.hammer, shopStock: shopStock),
          const SizedBox(width: 12),
          _shopCard(ShopItems.shuffle, shopStock: shopStock),
          const SizedBox(width: 12),
          _shopCard(ShopItems.extraMoves, shopStock: shopStock),
        ],
      ),
    );
  }

  Widget _buildCoinPackItems() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _shopCard(ShopItems.coins1000),
          const SizedBox(width: 12),
          _shopCard(ShopItems.coins3000),
          const SizedBox(width: 12),
          _shopCard(ShopItems.coins10000),
        ],
      ),
    );
  }

  Widget _buildPremiumItems() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _shopCard(ShopItems.removeAds),
          const SizedBox(width: 12),
          _shopCard(ShopItems.starterPack),
        ],
      ),
    );
  }

  Widget _shopCard(ShopItem item, {Map<String, int>? shopStock}) {
    final bool isOwned = shopStock != null && (shopStock[item.productId ?? item.id] ?? 0) > 0;

    return GestureDetector(
      onTap: () => _handlePurchase(item),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOwned ? const Color(0xFF2ECC71) : const Color(0xFF2C3E50),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            if (isOwned)
              const Text('OWNED', style: TextStyle(color: Color(0xFF2ECC71), fontSize: 11)),
            if (!isOwned)
              Text(
                item.isIAP ? '\$${item.productId ?? item.id}' : '${item.coinCost} coins',
                style: const TextStyle(color: Color(0xFFF0C040), fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }
}