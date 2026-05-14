// =============================================================================
// BACKGROUND COMPONENT (Flame) — Lint fixes applied
// =============================================================================

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BackgroundComponent extends PositionComponent {
  final List<_GlowOrb> _orbs = [];
  final List<_FloatingParticle> _particles = [];

  BackgroundComponent(Vector2 viewportSize) : super(size: viewportSize);

  @override
  void onMount() {
    super.onMount();

    _orbs
      ..add(_GlowOrb(
        color: const Color.fromRGBO(30, 18, 48, 1.0),
        baseX: size.x * 0.3,
        baseY: size.y * 0.4,
        orbitRadiusX: 120,
        orbitRadiusY: 80,
        frequency: 0.3,
        sizes: const [180.0, 120.0, 70.0],
        alphas: const [0.025, 0.019, 0.011],
      ))
      ..add(_GlowOrb(
        color: const Color.fromRGBO(10, 31, 54, 1.0),
        baseX: size.x * 0.7,
        baseY: size.y * 0.6,
        orbitRadiusX: 100,
        orbitRadiusY: 90,
        frequency: 0.3,
        sizes: const [180.0, 120.0, 70.0],
        alphas: const [0.025, 0.019, 0.011],
      ));

    final rng = Random(42);
    for (var i = 0; i < 20; i++) {
      _particles.add(_FloatingParticle(
        x: rng.nextDouble() * size.x,
        y: rng.nextDouble() * size.y,
        size: 1.5 + rng.nextDouble() * 2.0,
        alpha: 0.04 + rng.nextDouble() * 0.08,
        velocityX: -5 + rng.nextDouble() * 10,
        velocityY: -10 + rng.nextDouble() * (-2),
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final orb in _orbs) {
      orb.update();
    }
    for (final p in _particles) {
      p.update(dt, size.y);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFF0A0A14),
    );

    final stripWidth = size.x / 12;
    for (var i = 0; i < 12; i++) {
      final shade = 0.03 + (i % 3) * 0.015;
      canvas.drawRect(
        Rect.fromLTWH(i * stripWidth, 0, stripWidth + 1, size.y),
        Paint()..color = Color.fromRGBO(30, 20, 60, shade),
      );
    }

    for (final orb in _orbs) {
      orb.render(canvas);
    }
    for (final p in _particles) {
      p.render(canvas);
    }
  }
}

class _GlowOrb {
  final Color color;
  final double baseX, baseY;
  final double orbitRadiusX, orbitRadiusY;
  final double frequency;
  final List<double> sizes;
  final List<double> alphas;

  _GlowOrb({
    required this.color,
    required this.baseX,
    required this.baseY,
    required this.orbitRadiusX,
    required this.orbitRadiusY,
    required this.frequency,
    required this.sizes,
    required this.alphas,
  });

  void update() {}

  void render(Canvas canvas) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000;
    final x = baseX + orbitRadiusX * sin(time * frequency * 2 * pi);
    final y = baseY + orbitRadiusY * cos(time * frequency * 2 * pi);

    for (var i = 0; i < sizes.length; i++) {
      canvas.drawCircle(
        Offset(x, y),
        sizes[i] / 2,
        Paint()..color = color.withValues(alpha: alphas[i]),
      );
    }
  }
}

class _FloatingParticle {
  double x, y;
  final double size;
  final double alpha;
  final double velocityX, velocityY;

  _FloatingParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.alpha,
    required this.velocityX,
    required this.velocityY,
  });

  void update(double dt, double viewportHeight) {
    x += velocityX * dt;
    y += velocityY * dt;
    if (y < -10) {
      y = viewportHeight + 10;
      x = Random().nextDouble() * 720;
    }
    if (x < -10) x = 730;
    if (x > 730) x = -10;
  }

  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(x, y),
      size,
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: alpha),
    );
  }
}