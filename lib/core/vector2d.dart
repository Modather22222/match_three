// =============================================================================
// SIMPLE VECTOR2 CLASS (Pure Dart, no dependencies)
// =============================================================================

import 'dart:math';

/// A minimal 2D vector class for the engine layer.
/// Kept intentionally simple — no external dependencies.
class Vec2 {
  double x;
  double y;

  Vec2(this.x, this.y);

  Vec2.zero() : x = 0, y = 0;

  Vec2 operator +(Vec2 other) => Vec2(x + other.x, y + other.y);
  Vec2 operator -(Vec2 other) => Vec2(x - other.x, y - other.y);
  Vec2 operator *(double scalar) => Vec2(x * scalar, y * scalar);
  Vec2 operator /(double scalar) => Vec2(x / scalar, y / scalar);

  double get length => sqrt(x * x + y * y);
  double get lengthSquared => x * x + y * y;

  double manhattanDistance(Vec2 other) {
    return (x - other.x).abs() + (y - other.y).abs();
  }

  @override
  bool operator ==(Object other) =>
      other is Vec2 && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Vec2($x, $y)';
}