// =============================================================================
// LEVEL SELECT SCREEN (Reactive)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_game/core/constants.dart';
import 'package:flutter_game/models/level_record.dart';
import 'package:flutter_game/providers/save_provider.dart';
import 'package:flutter_game/widgets/level_button.dart';

/// Helper to safely access level records.
LevelRecord? getLevelRecord(Map<int, LevelRecord> levels, int key) {
  return levels.containsKey(key) ? levels[key]! : null;
}

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saveData = ref.watch(saveDataProvider);
    final coins = saveData.coins;
    final lives = saveData.lives;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF0A0A14)),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'SELECT LEVEL',
                        style: TextStyle(
                          color: Color(0xFFF0C040),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white70),
                        onPressed: () => Navigator.pushNamed(context, '/shop'),
                      ),
                    ],
                  ),
                ),

                // Status bar: lives, coins
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF0C040), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Lives indicator
                      Row(
                        children: [
                          ...List.generate(5, (i) => Text(
                            i < lives ? '♥' : '♡',
                            style: TextStyle(
                              fontSize: 16,
                              color: i < lives ? Colors.red : Colors.white38,
                            ),
                          )),
                          const SizedBox(width: 8),
                          Text('$lives/5', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                      // Timer (cosmetic)
                      const Text('∞', style: TextStyle(color: Color(0xFFF0C040), fontSize: 14)),
                      // Coins
                      Row(
                        children: [
                          const Text('💰 ', style: TextStyle(fontSize: 16)),
                          Text('$coins', style: const TextStyle(color: Color(0xFFF0C040), fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Level grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: maxLevels,
                    itemBuilder: (context, index) {
                      final levelNum = index + 1;
                      final record = getLevelRecord(saveData.levels, levelNum);
                      final isUnlocked = levelNum <= 1 || (saveData.levels[levelNum - 1] != null && saveData.levels[levelNum - 1]!.stars > 0);
                      return LevelButton(
                        levelNumber: levelNum,
                        stars: record?.stars ?? 0,
                        isUnlocked: isUnlocked,
                        onTap: () {
                          if (isUnlocked) {
                            Navigator.pushNamed(context, '/game', arguments: levelNum);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}