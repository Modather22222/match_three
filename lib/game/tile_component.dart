// =============================================================================
// TILE COMPONENT (Flame)
// =============================================================================

import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/core/constants.dart';
import 'package:flutter_game/core/extensions.dart';
import 'package:flutter_game/models/tile_model.dart';

/// A Flame PositionComponent that renders a single tile on the board.
class TileComponent extends PositionComponent {
  final TileModel model;

  TileState state = TileState.idle;
  double animProgress = 0.0;
  double glowOpacity = 0.0;
  double tileOpacity = 1.0;

  TileComponent({
    required this.model,
    required super.position,
    required super.size,
    super.anchor = Anchor.center,
  });

  static final _dropShadowPaint = Paint()
    ..color = const Color(0x4D000000)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

  static const _tileColors = [
    Color(0xFFE74C3C),
    Color(0xFF3498DB),
    Color(0xFF2ECC71),
    Color(0xFFF1C40F),
    Color(0xFF9B59B6),
  ];

  static const _tileSymbols = ['●', '■', '▲', '◆', '★'];

  Color get _tileColor => _tileColors[model.tileType.clamp(0, 4)];
  String get _symbol => _tileSymbols[model.tileType.clamp(0, 4)];

  @override
  void update(double dt) {
    super.update(dt);
    animProgress += dt;
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(position.x, position.y);

    final rect = size.toRect();
    final center = size / 2;
    final double o = tileOpacity;

    // 1. Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(2, 3)), const Radius.circular(6)),
      _dropShadowPaint,
    );

    // 2. Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(3), const Radius.circular(5)),
      Paint()..color = _tileColor.withValues(alpha: o),
    );

    // 3. Highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(3, 3, size.x - 6, size.y * 0.38), const Radius.circular(3)),
      Paint()..color = _tileColor.lighten(0.35).withValues(alpha: o),
    );

    // 4. Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(3), const Radius.circular(5)),
      Paint()..color = _tileColor.darken(0.3).withValues(alpha: o)..style = PaintingStyle.stroke..strokeWidth = 2,
    );

    // 5. Selection glow
    if (state == TileState.selected || glowOpacity > 0) {
      final double ga = glowOpacity.clamp(0.0, 1.0) * o;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(-3), const Radius.circular(8)),
        Paint()..color = Color.fromRGBO(255, 255, 255, ga)..style = PaintingStyle.stroke..strokeWidth = 3,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(-5), const Radius.circular(10)),
        Paint()..color = Color.fromRGBO(255, 192, 64, ga)..style = PaintingStyle.stroke..strokeWidth = 1.5,
      );
    }

    // 6. Symbol
    _drawTextCentered(canvas, _symbol, center, Color.fromRGBO(255, 255, 255, 0.887 * o), size.x * 0.36);

    // 7. Special overlays
    _renderSpecial(canvas, rect, center);

    canvas.restore();
  }

  void _renderSpecial(Canvas canvas, Rect rect, Vector2 center) {
    final double o = tileOpacity;
    switch (model.specialType) {
      case SpecialType.stripedH:
        final midY = size.y / 2;
        canvas
          ..drawLine(Offset(0, midY), Offset(size.x, midY), Paint()..color = Color.fromRGBO(255, 255, 255, 0.855 * o)..strokeWidth = 3)
          ..drawLine(Offset(0, midY - 8), Offset(size.x, midY - 8), Paint()..color = Color.fromRGBO(255, 255, 255, 0.4 * o)..strokeWidth = 1.5)
          ..drawLine(Offset(0, midY + 8), Offset(size.x, midY + 8), Paint()..color = Color.fromRGBO(255, 255, 255, 0.4 * o)..strokeWidth = 1.5);
        break;
      case SpecialType.stripedV:
        final midX = size.x / 2;
        canvas
          ..drawLine(Offset(midX, 0), Offset(midX, size.y), Paint()..color = Color.fromRGBO(255, 255, 255, 0.855 * o)..strokeWidth = 3)
          ..drawLine(Offset(midX - 8, 0), Offset(midX - 8, size.y), Paint()..color = Color.fromRGBO(255, 255, 255, 0.4 * o)..strokeWidth = 1.5)
          ..drawLine(Offset(midX + 8, 0), Offset(midX + 8, size.y), Paint()..color = Color.fromRGBO(255, 255, 255, 0.4 * o)..strokeWidth = 1.5);
        break;
      case SpecialType.wrapped:
        canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(5)), Paint()..color = Color.fromRGBO(255, 255, 255, 0.451 * o)..style = PaintingStyle.stroke..strokeWidth = 3);
        final cp = Paint()..color = Color.fromRGBO(255, 255, 255, 0.749 * o);
        const cs = 7.0;
        canvas
          ..drawRect(Rect.fromLTWH(0, 0, cs, cs), cp)
          ..drawRect(Rect.fromLTWH(size.x - cs, 0, cs, cs), cp)
          ..drawRect(Rect.fromLTWH(0, size.y - cs, cs, cs), cp)
          ..drawRect(Rect.fromLTWH(size.x - cs, size.y - cs, cs, cs), cp);
        break;
      case SpecialType.colorBomb:
        final hue = (animProgress * 0.25) % 1.0;
        final hsl = HSLColor.fromAHSL(1.0, hue * 360, 1.0, 0.5);
        canvas
          ..drawRRect(RRect.fromRectAndRadius(rect.deflate(3), const Radius.circular(5)), Paint()..color = hsl.toColor().withValues(alpha: o))
          ..drawRRect(RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(4)), Paint()..color = Color.fromRGBO(255, 255, 255, 0.502 * o)..style = PaintingStyle.stroke..strokeWidth = 2);
        final orbitRadius = size.x * 0.28;
        for (var i = 0; i < 5; i++) {
          final angle = animProgress * 2 + i * (2 * math.pi / 5);
          canvas.drawCircle(Offset(center.x + orbitRadius * math.cos(angle), center.y + orbitRadius * math.sin(angle)), 3, Paint()..color = _tileColor.lighten(0.5).withValues(alpha: o));
        }
        _drawTextCentered(canvas, '✦', center, Color.fromRGBO(255, 255, 255, 1.0 * o), size.x * 0.36);
        break;
      default:
        break;
    }
  }

  void _drawTextCentered(Canvas canvas, String text, Vector2 center, Color color, double fontSize) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, color: color)),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(canvas, Offset(center.x - painter.width / 2, center.y - painter.height / 2));
  }

  void startShrink() {
    state = TileState.shrinking;
    animProgress = 0;
    add(ScaleEffect.by(Vector2.zero(), EffectController(duration: animClear)));
  }

  void startFall(double rowsDistance) {
    state = TileState.falling;
    animProgress = 0;
    add(MoveEffect.by(Vector2(0, rowsDistance * tileSize), EffectController(duration: animGravityBase + animGravityPerRow * rowsDistance)));
  }

  void startSpecialPop() {
    state = TileState.specialPop;
    animProgress = 0;
    add(ScaleEffect.by(Vector2.all(0.6), EffectController(duration: animSpecialPop1, curve: Curves.easeOut)));
  }

  void startDrop(double rowsDistance, int dropIndex) {
    state = TileState.dropping;
    animProgress = 0;
    add(MoveEffect.by(
      Vector2(0, -rowsDistance * tileSize),
      EffectController(duration: animRefillBase + animRefillPerRow * rowsDistance),
    ));
  }
}

enum TileState { idle, selected, shrinking, falling, dropping, specialPop }