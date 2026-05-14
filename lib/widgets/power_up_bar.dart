// =============================================================================
// POWER-UP BAR WIDGET
// =============================================================================

import 'package:flutter/material.dart';

class PowerUpBar extends StatelessWidget {
  final int hammers;
  final int shuffles;
  final int extraMoves;
  final VoidCallback onHammer;
  final VoidCallback onShuffle;
  final VoidCallback onExtraMoves;
  final VoidCallback onRestart;

  const PowerUpBar({
    super.key,
    required this.hammers,
    required this.shuffles,
    required this.extraMoves,
    required this.onHammer,
    required this.onShuffle,
    required this.onExtraMoves,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2C3E50),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _powerUpButton(
              icon: '🔨',
              label: hammers > 0 ? '×$hammers' : '50💰',
              enabled: hammers > 0,
              onTap: onHammer,
            ),
            _powerUpButton(
              icon: '🔀',
              label: shuffles > 0 ? '×$shuffles' : '30💰',
              enabled: shuffles > 0,
              onTap: onShuffle,
            ),
            _powerUpButton(
              icon: '+5',
              label: extraMoves > 0 ? '×$extraMoves' : '40💰',
              enabled: extraMoves > 0,
              onTap: onExtraMoves,
            ),
            _powerUpButton(
              icon: '↺',
              label: '',
              enabled: true,
              onTap: onRestart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _powerUpButton({
    required String icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 80,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF34495E) : const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(8),
          border: enabled
              ? Border.all(color: const Color(0xFFF0C040), width: 1)
              : Border.all(color: Colors.grey, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            if (label.isNotEmpty)
              Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFFF0C040))),
          ],
        ),
      ),
    );
  }
}