// =============================================================================
// SCORE POPUP COMPONENT (Flame)
// =============================================================================

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/core/constants.dart';

/// Floating score label that appears at a position and drifts upward.
class ScorePopupComponent extends PositionComponent {
  final String text;
  final double baseFontSize;

  ScorePopupComponent({
    required Vector2 position,
    required this.text,
    this.baseFontSize = scorePopupBaseSize,
  }) : super(
          position: position,
          size: Vector2(100, 30),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      SequenceEffect([
        OpacityEffect.to(
          0,
          EffectController(
            duration: scorePopupDuration,
            alternate: false,
          ),
        ),
        RemoveEffect(),
      ]),
    );
    add(
      MoveByEffect(
        Vector2(0, -scorePopupFloatDistance),
        EffectController(duration: scorePopupDuration),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: baseFontSize,
          color: const Color(0xFFF0C040),
          fontWeight: FontWeight.w900,
          shadows: const [
            Shadow(
              offset: Offset(1, 2),
              blurRadius: 4,
              color: Color(0x80000000),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(-painter.width / 2, -painter.height / 2),
    );
  }
}

/// Combo score popup with larger text for multi-match combos.
class ComboPopupComponent extends PositionComponent {
  final String text;

  ComboPopupComponent({
    required Vector2 position,
    required this.text,
  }) : super(
          position: position,
          size: Vector2(100, 40),
          anchor: Anchor.center,
        );

  double _scale = 0.5;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      SequenceEffect([
        OpacityEffect.to(
          0,
          EffectController(duration: scorePopupDuration),
        ),
        RemoveEffect(),
      ]),
    );
    add(
      MoveByEffect(
        Vector2(0, -scorePopupFloatDistance * 1.3),
        EffectController(duration: scorePopupDuration),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _scale += (1.0 - _scale) * 0.1;
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(position.x, position.y);
    canvas.scale(_scale, _scale);

    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: scorePopupBaseSize + scorePopupComboIncrement * 2,
          color: Color(0xFFFFD700),
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              offset: Offset(1, 2),
              blurRadius: 6,
              color: Color(0x80000000),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(-painter.width / 2, -painter.height / 2),
    );

    canvas.restore();
  }
}