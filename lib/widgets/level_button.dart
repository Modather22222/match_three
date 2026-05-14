// =============================================================================
// LEVEL BUTTON WIDGET
// =============================================================================

import 'package:flutter/material.dart';

class LevelButton extends StatelessWidget {
  final int levelNumber;
  final int stars; // 0-3
  final bool isUnlocked;
  final VoidCallback onTap;

  const LevelButton({
    super.key,
    required this.levelNumber,
    required this.stars,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: _gradient(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor(), width: 2),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$levelNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _starsWidget(),
                ],
              ),
            ),
            if (!isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Icon(Icons.lock, color: Colors.white54, size: 24)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  LinearGradient _gradient() {
    if (!isUnlocked) {
      return const LinearGradient(colors: [Color(0xFF2C2C3E), Color(0xFF1A1A2E)]);
    }
    switch (stars) {
      case 3:
        return const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFB8860B)]);
      case 2:
        return const LinearGradient(colors: [Color(0xFF2ECC71), Color(0xFF27AE60)]);
      case 1:
        return const LinearGradient(colors: [Color(0xFF2C3E50), Color(0xFF1A252F)]);
      default:
        return const LinearGradient(colors: [Color(0xFF34495E), Color(0xFF2C3E50)]);
    }
  }

  Color _borderColor() {
    if (!isUnlocked) return Colors.grey;
    switch (stars) {
      case 3: return const Color(0xFFD4AF37);
      case 2: return const Color(0xFF2ECC71);
      case 1: return const Color(0xFF3498DB);
      default: return const Color(0xFF34495E);
    }
  }

  Widget _starsWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        if (i < stars) {
          return const Text('★', style: TextStyle(color: Color(0xFFFFD700), fontSize: 10));
        }
        return const Text('☆', style: TextStyle(color: Colors.white38, fontSize: 10));
      }),
    );
  }
}