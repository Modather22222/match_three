// =============================================================================
// HAMMER MODE OVERLAY (Flame Component)
// =============================================================================

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Visual indicator for hammer mode — pulsing border around the board.
class HammerModeOverlay extends PositionComponent {
  double _pulsePhase = 0;

  HammerModeOverlay()
      : super(
          position: Vector2.zero(),
          size: Vector2(608, 608),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _pulsePhase += dt * 3;
  }

  @override
  void render(Canvas canvas) {
    final alpha = ((sin(_pulsePhase) + 1) / 2 * 0.6 + 0.4);
    final paint = Paint()
      ..color = Color.fromRGBO(255, 140, 0, alpha.clamp(0.0, 1.0).toDouble())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(12),
      ),
      paint,
    );
  }
}