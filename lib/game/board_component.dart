// =============================================================================
// BOARD COMPONENT (Flame)
// =============================================================================

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/core/constants.dart';

/// Flame component that renders the board background (dark panel + checkerboard).
class BoardComponent extends PositionComponent {
  BoardComponent()
      : super(
          position: Vector2(boardOffsetX, boardOffsetY),
          size: Vector2(
              (boardCols * tileSize).toDouble(),
              (boardRows * tileSize).toDouble()),
        );

  @override
  void render(Canvas canvas) {
    // 1. Dark panel with rounded rectangle
    final panelPaint = Paint()
      ..color = const Color(0x59000000)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-10, -10, size.x + 20, size.y + 20),
        const Radius.circular(12),
      ),
      panelPaint,
    );

    // Subtle border
    final borderPaint = Paint()
      ..color = const Color(0x14FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-10, -10, size.x + 20, size.y + 20),
        const Radius.circular(12),
      ),
      borderPaint,
    );

    // 2. Checkerboard cell shading
    for (int c = 0; c < boardCols; c++) {
      for (int r = 0; r < boardRows; r++) {
        final double x = c * tileSize.toDouble();
        final double y = r * tileSize.toDouble();
        final isEven = (c + r) % 2 == 0;
        final paint = Paint()
          ..color = isEven
              ? const Color(0x0F000000)
              : const Color(0x06000000)
          ..style = PaintingStyle.fill;
        canvas.drawRect(Rect.fromLTWH(x, y, tileSize.toDouble(), tileSize.toDouble()), paint);
      }
    }
  }
}