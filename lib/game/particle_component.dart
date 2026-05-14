// =============================================================================
// PARTICLE COMPONENT (Flame)
// =============================================================================

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ParticleComponent extends PositionComponent {
  final double startOpacity;
  final double endOpacity;
  final double startRadius;
  final double endRadius;
  final Color color;
  final Vector2 velocity;
  final double duration;

  double _elapsed = 0;
  double _currentRadius = 0;
  double _currentOpacity = 0;

  ParticleComponent({
    required this.startOpacity,
    required this.endOpacity,
    required this.startRadius,
    required this.endRadius,
    required this.color,
    required this.velocity,
    required this.duration,
    required Vector2 position,
  })  : _currentRadius = startRadius,
        _currentOpacity = startOpacity,
        super(
          position: position,
          size: Vector2.all(startRadius * 2),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    _currentRadius = startRadius + (endRadius - startRadius) * progress;
    _currentOpacity = startOpacity * (1 - progress);

    position.x += velocity.x * dt;
    position.y += velocity.y * dt;

    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset.zero,
      _currentRadius,
      Paint()..color = color.withValues(alpha: _currentOpacity),
    );
  }

  static void spawnBurst(
    PositionComponent parent,
    Vector2 position,
    Color baseColor, {
    int count = 5,
    double minRadius = 3,
    double maxRadius = 14,
    double baseOpacity = 0.65,
    double duration = 0.35,
    double speedMin = -10,
    double speedMax = 10,
  }) {
    final random = Random();
    for (var i = 0; i < count; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = speedMin + random.nextDouble() * (speedMax - speedMin);
      final vel = Vector2(speed * cos(angle), speed * sin(angle));
      final radius = minRadius + random.nextDouble() * (maxRadius - minRadius);
      final particleColor =
          Color.lerp(baseColor, Colors.white, random.nextDouble() * 0.5) ??
              baseColor;

      parent.add(
        ParticleComponent(
          position: position,
          startOpacity: baseOpacity,
          endOpacity: 0,
          startRadius: radius,
          endRadius: radius * 2,
          color: particleColor,
          velocity: vel,
          duration: duration,
        ),
      );
    }
  }
}