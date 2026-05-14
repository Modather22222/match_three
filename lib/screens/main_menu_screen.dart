// =============================================================================
// MAIN MENU SCREEN (Reactive)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_game/providers/save_provider.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> {
  @override
  Widget build(BuildContext context) {
    final coins = ref.watch(saveDataProvider).coins;
    final lives = ref.watch(saveDataProvider).lives;
    final currentLevel = ref.watch(saveDataProvider).currentLevel;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF0A0A14)),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Title
                Text(
                  'MATCH\nTHREE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.12,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFF0C040),
                    shadows: const [
                      Shadow(
                        offset: Offset(2, 4),
                        blurRadius: 12,
                        color: Color(0x80000000),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle
                Text(
                  '◆ Tile Puzzle ◆',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),

                const Spacer(flex: 2),

                // PLAY button
                _MenuButton(
                  text: 'PLAY',
                  width: 300,
                  height: 72,
                  color: const Color(0xFF27AE60),
                  onPressed: () => Navigator.pushNamed(context, '/level-select'),
                ),

                const SizedBox(height: 12),

                // Level indicator
                Text(
                  'Level $currentLevel',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white54,
                  ),
                ),

                const SizedBox(height: 20),

                // SHOP button
                _MenuButton(
                  text: 'SHOP',
                  width: 200,
                  height: 48,
                  color: const Color(0xFF8E44AD),
                  onPressed: () => Navigator.pushNamed(context, '/shop'),
                ),

                const SizedBox(height: 12),

                // Coins display (reactive)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('💰 ', style: TextStyle(fontSize: 16)),
                    Text(
                      '$coins',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFFF0C040),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 3),

                // Lives display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(5, (i) => Text(
                      i < lives ? '♥ ' : '♡ ',
                      style: TextStyle(
                        fontSize: 22,
                        color: i < lives ? Colors.red : Colors.white38,
                      ),
                    )),
                    const SizedBox(width: 8),
                    Text(
                      '$lives/5',
                      style: const TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Sound toggle
                Container(
                  width: 220,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3E50),
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.volume_up, size: 18, color: Colors.white70),
                        SizedBox(width: 8),
                        Text('Sound On', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.text,
    required this.width,
    required this.height,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          elevation: 4,
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}