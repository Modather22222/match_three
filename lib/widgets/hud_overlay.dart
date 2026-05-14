// =============================================================================
// HUD OVERLAY
// =============================================================================

import 'package:flutter/material.dart';

class HUDOverlay extends StatelessWidget {
  final int score;
  final int targetScore;
  final int movesRemaining;
  final int coins;
  final int level;

  const HUDOverlay({
    super.key,
    required this.score,
    required this.targetScore,
    required this.movesRemaining,
    required this.coins,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        children: [
          // Top bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xCC0A0A14), Color(0x000A0A14)],
              ),
            ),
            child: Row(
              children: [
                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 24),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),

                // Coins
                Row(
                  children: [
                    const Text('💰', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text('$coins', style: const TextStyle(color: Color(0xFFF0C040), fontWeight: FontWeight.w600, fontSize: 16)),
                  ],
                ),
                const Spacer(),

                // Title
                Text('MATCH THREE', style: const TextStyle(color: Color(0xFFF0C040), fontSize: 18, fontWeight: FontWeight.w900)),
                const Spacer(),

                // Level
                Text('Level $level', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          const SizedBox(height: 35),

          // Score & Moves bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score
                Column(
                  children: [
                    const Text('Score', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text('$score', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),

                // Target
                Column(
                  children: [
                    const Text('Target', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text('$targetScore', style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),

                // Moves
                Column(
                  children: [
                    const Text('Moves', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text('$movesRemaining', style: TextStyle(
                      color: movesRemaining > 5 ? Colors.white : (movesRemaining > 2 ? const Color(0xFFF39C12) : const Color(0xFFE74C3C)),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    )),
                  ],
                ),
              ],
            ),
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (score / targetScore).clamp(0.0, 1.0),
                backgroundColor: const Color(0xFF1A1A2E),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
                minHeight: 6,
              ),
            ),
          ),

          // Status text placeholder (shown conditionally via overlay)
          const Spacer(),
        ],
      ),
    );
  }
}