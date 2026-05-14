// =============================================================================
// BOARD ENGINE
// =============================================================================

import 'dart:math';
import 'package:flutter_game/core/constants.dart';
import 'package:flutter_game/core/vector2d.dart';
import 'package:flutter_game/models/tile_model.dart';

/// Pure Dart board logic — no Flame or Flutter dependencies.
class Board {
  List<List<TileModel?>> grid;

  int cols;
  int rows;
  int numTileTypes;

  final Random _rng = Random();

  Board({
    this.cols = boardCols,
    this.rows = boardRows,
    this.numTileTypes = numTileTypesFull,
  }) : grid = List.generate(cols, (_) => List.filled(rows, null));

  Vec2 gridToWorld(int col, int row) {
    return Vec2(
      boardOffsetX + col * tileSize.toDouble(),
      boardOffsetY + row * tileSize.toDouble(),
    );
  }

  Vec2 worldToGrid(double worldX, double worldY) {
    final col = ((worldX - boardOffsetX) / tileSize).floor();
    final row = ((worldY - boardOffsetY) / tileSize).floor();
    if (isInBounds(col, row)) {
      return Vec2(col.toDouble(), row.toDouble());
    }
    return Vec2(-1, -1);
  }

  bool isInBounds(int col, int row) {
    return col >= 0 && col < cols && row >= 0 && row < rows;
  }

  static bool isAdjacent(int col1, int row1, int col2, int row2) {
    return (col1 - col2).abs() + (row1 - row2).abs() == 1;
  }

  TileModel? getTile(int col, int row) {
    if (!isInBounds(col, row)) return null;
    return grid[col][row];
  }

  void setTile(int col, int row, TileModel? tile) {
    if (isInBounds(col, row)) {
      grid[col][row] = tile;
    }
  }

  int get tileCount {
    int count = 0;
    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows; r++) {
        if (grid[c][r] != null) count++;
      }
    }
    return count;
  }

  void generateBoard() {
    for (int col = 0; col < cols; col++) {
      for (int row = 0; row < rows; row++) {
        grid[col][row] = _generateTileNoMatch(col, row);
      }
    }
  }

  TileModel _generateTileNoMatch(int col, int row) {
    int attempts = 0;
    const maxAttempts = 100;

    while (attempts < maxAttempts) {
      final type = _rng.nextInt(numTileTypes);
      if (col >= 2 &&
          grid[col - 1][row]?.tileType == type &&
          grid[col - 2][row]?.tileType == type) {
        attempts++;
        continue;
      }
      if (row >= 2 &&
          grid[col][row - 1]?.tileType == type &&
          grid[col][row - 2]?.tileType == type) {
        attempts++;
        continue;
      }
      return TileModel(tileType: type, gridCol: col, gridRow: row);
    }

    return TileModel(tileType: _rng.nextInt(numTileTypes), gridCol: col, gridRow: row);
  }

  bool swapTiles(int col1, int row1, int col2, int row2) {
    if (!isInBounds(col1, row1) || !isInBounds(col2, row2)) return false;
    if (!isAdjacent(col1, row1, col2, row2)) return false;

    final temp = grid[col1][row1];
    grid[col1][row1] = grid[col2][row2];
    grid[col2][row2] = temp;

    if (grid[col1][row1] != null) {
      grid[col1][row1] = grid[col1][row1]!.copyWith(gridCol: col1, gridRow: row1);
    }
    if (grid[col2][row2] != null) {
      grid[col2][row2] = grid[col2][row2]!.copyWith(gridCol: col2, gridRow: row2);
    }

    return true;
  }

  SwapResult performSwap(int col1, int row1, int col2, int row2) {
    final tile1 = getTile(col1, row1);
    final tile2 = getTile(col2, row2);

    if (tile1 == null || tile2 == null) return SwapResult.failed('null tile');
    if (!isAdjacent(col1, row1, col2, row2)) return SwapResult.failed('not adjacent');

    if (tile1.isColorBomb || tile2.isColorBomb) {
      swapTiles(col1, row1, col2, row2);
      return SwapResult.success(isBombSwap: true);
    }

    swapTiles(col1, row1, col2, row2);
    return SwapResult.success();
  }

  @override
  String toString() {
    final sb = StringBuffer();
    for (int row = rows - 1; row >= 0; row--) {
      for (int col = 0; col < cols; col++) {
        final tile = grid[col][row];
        if (tile == null) {
          sb.write(' . ');
        } else {
          sb.write(' ${tile.tileType}${tile.specialType != SpecialType.none ? "*" : "   "}');
        }
      }
      sb.writeln();
    }
    return sb.toString();
  }
}

class SwapResult {
  final bool success;
  final String? errorMessage;
  final bool isBombSwap;

  SwapResult.success({this.isBombSwap = false})
      : success = true,
        errorMessage = null;

  SwapResult.failed(this.errorMessage)
      : success = false,
        isBombSwap = false;
}