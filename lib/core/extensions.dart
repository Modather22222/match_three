// =============================================================================
// UTILITY EXTENSIONS
// =============================================================================

import 'dart:math';

import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  /// Lighten a color by the given amount (0.0 to 1.0)
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Darken a color by the given amount (0.0 to 1.0)
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Get color from hex int value
  static Color fromHex(int hexValue) {
    return Color(hexValue);
  }
}

extension IntExtensions on int {
  /// Clamp an integer between min and max (inclusive)
  int clampInt(int min, int max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}

extension DoubleExtensions on double {
  /// Map a value from one range to another
  double mapRange(double fromMin, double fromMax, double toMin, double toMax) {
    return toMin + (this - fromMin) * (toMax - toMin) / (fromMax - fromMin);
  }

  /// Round to given decimal places
  double roundTo(int places) {
    final factor = pow(10, places);
    return (this * factor).round() / factor;
  }
}

extension List2DExtensions<T> on List<List<T?>> {
  /// Check if grid coordinates are in bounds
  bool isInBounds(int col, int row) {
    return col >= 0 && col < length && row >= 0 && row < this[0].length;
  }

  /// Check if two positions are adjacent (Manhattan distance == 1)
  static bool isAdjacent(int col1, int row1, int col2, int row2) {
    return (col1 - col2).abs() + (row1 - row2).abs() == 1;
  }
}