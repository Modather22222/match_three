// =============================================================================
// INPUT HANDLER
// =============================================================================

import 'package:flutter_game/core/constants.dart';
import 'package:flutter_game/core/vector2d.dart';
import 'package:flutter_game/engine/board.dart';

/// Handles all player input for the match-3 game.
class InputHandler {
  final Board board;

  InputHandler(this.board);

  bool pointerHeld = false;
  Vec2? _downPosition;
  Vec2? _selectedTile;
  bool hammerMode = false;
  bool isProcessing = false;
  bool popupActive = false;

  /// Callback invoked when a tile is tapped in hammer mode.
  void Function(int col, int row)? onHammerTap;

  Vec2? onPointerDown(double worldX, double worldY) {
    if (isProcessing || popupActive) return null;

    final gridPos = board.worldToGrid(worldX, worldY);
    if (gridPos.x < 0 || gridPos.y < 0) return null;

    final col = gridPos.x.toInt();
    final row = gridPos.y.toInt();
    final tile = board.getTile(col, row);
    if (tile == null) return null;

    // Handle hammer mode tap
    if (hammerMode && onHammerTap != null) {
      onHammerTap!(col, row);
      return gridPos;
    }

    pointerHeld = true;
    _downPosition = gridPos;
    return gridPos;
  }

  SwapResult? onPointerMove(double worldX, double worldY) {
    if (!pointerHeld || isProcessing || popupActive || hammerMode) return null;
    if (_downPosition == null) return null;

    final dx = worldX - board.gridToWorld(_downPosition!.x.toInt(), 0).x;
    final dy = worldY - board.gridToWorld(0, _downPosition!.y.toInt()).y;

    if (dx.abs() > swipeThreshold || dy.abs() > swipeThreshold) {
      pointerHeld = false;

      final direction = _calculateDirection(dx, dy);
      if (direction == null) return null;

      final targetCol = _downPosition!.x.toInt() + direction.x.toInt();
      final targetRow = _downPosition!.y.toInt() + direction.y.toInt();

      if (!board.isInBounds(targetCol, targetRow)) return null;

      return board.performSwap(
        _downPosition!.x.toInt(),
        _downPosition!.y.toInt(),
        targetCol,
        targetRow,
      );
    }
    return null;
  }

  SwapResult? onPointerUp(double worldX, double worldY) {
    if (isProcessing || popupActive) {
      pointerHeld = false;
      return null;
    }

    if (hammerMode) {
      pointerHeld = false;
      return null;
    }

    final gridPos = board.worldToGrid(worldX, worldY);

    if (pointerHeld && _downPosition != null) {
      final dx = (gridPos.x - _downPosition!.x).abs();
      final dy = (gridPos.y - _downPosition!.y).abs();

      if (dx < 1 && dy < 1) {
        return _handleTap(gridPos);
      }
    }

    pointerHeld = false;
    return null;
  }

  SwapResult? _handleTap(Vec2 gridPos) {
    final col = gridPos.x.toInt();
    final row = gridPos.y.toInt();

    if (_selectedTile == null) {
      _selectedTile = gridPos;
      return null;
    }

    if (_selectedTile!.x.toInt() == col && _selectedTile!.y.toInt() == row) {
      _selectedTile = null;
      return null;
    }

    if (Board.isAdjacent(
      _selectedTile!.x.toInt(),
      _selectedTile!.y.toInt(),
      col,
      row,
    )) {
      final result = board.performSwap(
        _selectedTile!.x.toInt(),
        _selectedTile!.y.toInt(),
        col,
        row,
      );
      _selectedTile = null;
      return result;
    } else {
      _selectedTile = gridPos;
      return null;
    }
  }

  Vec2? _calculateDirection(double dx, double dy) {
    if (dx.abs() > dy.abs()) {
      return dx > 0 ? Vec2(1, 0) : Vec2(-1, 0);
    } else if (dy.abs() > dx.abs()) {
      return dy > 0 ? Vec2(0, 1) : Vec2(0, -1);
    }
    return null;
  }

  bool isSelected(int col, int row) {
    return _selectedTile != null &&
        _selectedTile!.x.toInt() == col &&
        _selectedTile!.y.toInt() == row;
  }

  void clearSelection() => _selectedTile = null;

  void reset() {
    pointerHeld = false;
    _downPosition = null;
    _selectedTile = null;
    hammerMode = false;
    isProcessing = false;
    popupActive = false;
    onHammerTap = null;
  }
}