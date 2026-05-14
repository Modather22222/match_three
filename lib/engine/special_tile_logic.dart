// =============================================================================
// SPECIAL TILE LOGIC
// =============================================================================

import 'package:flutter_game/core/constants.dart';
import 'package:flutter_game/core/vector2d.dart';
import 'package:flutter_game/engine/board.dart';

/// Manages special tile effects, combos, and recursive chain expansion.
class SpecialTileLogic {
  final Board board;

  SpecialTileLogic(this.board);

  List<Vec2> getSpecialEffectPositions(Vec2 pos, SpecialType type) {
    final col = pos.x.toInt();
    final row = pos.y.toInt();

    switch (type) {
      case SpecialType.stripedH:
        return _getRowPositions(col, row);
      case SpecialType.stripedV:
        return _getColumnPositions(col, row);
      case SpecialType.wrapped:
        return _getAreaPositions(col, row);
      case SpecialType.colorBomb:
        return [pos];
      case SpecialType.none:
        return [];
    }
  }

  List<Vec2> _getRowPositions(int bombCol, int row) {
    final positions = <Vec2>[];
    for (int c = 0; c < boardCols; c++) {
      if (c != bombCol) {
        positions.add(Vec2(c.toDouble(), row.toDouble()));
      }
    }
    return positions;
  }

  List<Vec2> _getColumnPositions(int col, int bombRow) {
    final positions = <Vec2>[];
    for (int r = 0; r < boardRows; r++) {
      if (r != bombRow) {
        positions.add(Vec2(col.toDouble(), r.toDouble()));
      }
    }
    return positions;
  }

  List<Vec2> _getAreaPositions(int col, int row) {
    final positions = <Vec2>[];
    for (int dc = -1; dc <= 1; dc++) {
      for (int dr = -1; dr <= 1; dr++) {
        if (dc == 0 && dr == 0) continue;
        final nc = col + dc;
        final nr = row + dr;
        if (board.isInBounds(nc, nr)) {
          positions.add(Vec2(nc.toDouble(), nr.toDouble()));
        }
      }
    }
    return positions;
  }

  List<Vec2> getColorBombTargets(int targetTileType) {
    final positions = <Vec2>[];
    for (int c = 0; c < boardCols; c++) {
      for (int r = 0; r < boardRows; r++) {
        final tile = board.getTile(c, r);
        if (tile != null && !tile.isColorBomb && !tile.isWrapped && !tile.isStriped && tile.tileType == targetTileType) {
          positions.add(Vec2(c.toDouble(), r.toDouble()));
        }
      }
    }
    return positions;
  }

  SpecialComboResult handleSpecialCombo(Vec2 pos1, SpecialType type1, Vec2 pos2, SpecialType type2) {
    final allPositions = <Vec2>{};

    if (type1 == SpecialType.colorBomb && type2 == SpecialType.colorBomb) {
      for (int c = 0; c < boardCols; c++) {
        for (int r = 0; r < boardRows; r++) {
          allPositions.add(Vec2(c.toDouble(), r.toDouble()));
        }
      }
      return SpecialComboResult(affectedPositions: allPositions.toList(), comboType: SpecialComboType.boardWipe);
    }

    if ((type1 == SpecialType.colorBomb && (type2 == SpecialType.stripedH || type2 == SpecialType.stripedV)) ||
        (type2 == SpecialType.colorBomb && (type1 == SpecialType.stripedH || type1 == SpecialType.stripedV))) {
      return _handleBombStripedCombo(
        bombPos: type1 == SpecialType.colorBomb ? pos1 : pos2,
        stripedPos: type1 == SpecialType.colorBomb ? pos2 : pos1,
        stripedType: type1 == SpecialType.colorBomb ? type2 : type1,
      );
    }

    if ((type1 == SpecialType.colorBomb && type2 == SpecialType.wrapped) ||
        (type2 == SpecialType.colorBomb && type1 == SpecialType.wrapped)) {
      return _handleBombWrappedCombo(
        bombPos: type1 == SpecialType.colorBomb ? pos1 : pos2,
        wrappedPos: type1 == SpecialType.colorBomb ? pos2 : pos1,
      );
    }

    if ((type1 == SpecialType.stripedH || type1 == SpecialType.stripedV) &&
        (type2 == SpecialType.stripedH || type2 == SpecialType.stripedV)) {
      return _handleStripedStripedCombo(type1, pos1, type2, pos2);
    }

    if ((type1 == SpecialType.stripedH || type1 == SpecialType.stripedV) && type2 == SpecialType.wrapped ||
        type1 == SpecialType.wrapped && (type2 == SpecialType.stripedH || type2 == SpecialType.stripedV)) {
      return _handleStripedWrappedCombo(type1, pos1, type2, pos2);
    }

    if (type1 == SpecialType.wrapped && type2 == SpecialType.wrapped) {
      return _handleWrappedWrappedCombo(pos1, pos2);
    }

    final pos1Effects = getSpecialEffectPositions(pos1, type1);
    final pos2Effects = getSpecialEffectPositions(pos2, type2);
    allPositions.addAll(pos1Effects);
    allPositions.addAll(pos2Effects);

    return SpecialComboResult(affectedPositions: allPositions.toList(), comboType: SpecialComboType.simultaneous);
  }

  SpecialComboResult _handleBombStripedCombo({
    required Vec2 bombPos,
    required Vec2 stripedPos,
    required SpecialType stripedType,
  }) {
    final stripedTile = board.getTile(stripedPos.x.toInt(), stripedPos.y.toInt());
    final targetColor = stripedTile?.tileType ?? 0;

    final affected = <Vec2>{};
    for (int c = 0; c < boardCols; c++) {
      for (int r = 0; r < boardRows; r++) {
        final tile = board.getTile(c, r);
        if (tile != null && tile.tileType == targetColor && !tile.isSpecial) {
          affected.add(Vec2(c.toDouble(), r.toDouble()));
          board.setTile(c, r, tile.copyWith(specialType: stripedType));
        }
      }
    }
    affected.add(bombPos);

    return SpecialComboResult(affectedPositions: affected.toList(), comboType: SpecialComboType.bombStriped);
  }

  SpecialComboResult _handleBombWrappedCombo({
    required Vec2 bombPos,
    required Vec2 wrappedPos,
  }) {
    final wrappedTile = board.getTile(wrappedPos.x.toInt(), wrappedPos.y.toInt());
    final targetColor = wrappedTile?.tileType ?? 0;

    final affected = <Vec2>{};
    for (int c = 0; c < boardCols; c++) {
      for (int r = 0; r < boardRows; r++) {
        final tile = board.getTile(c, r);
        if (tile != null && tile.tileType == targetColor && !tile.isSpecial) {
          affected.add(Vec2(c.toDouble(), r.toDouble()));
          board.setTile(c, r, tile.copyWith(specialType: SpecialType.wrapped));
        }
      }
    }
    affected.add(bombPos);

    return SpecialComboResult(affectedPositions: affected.toList(), comboType: SpecialComboType.bombWrapped);
  }

  SpecialComboResult _handleStripedStripedCombo(SpecialType type1, Vec2 pos1, SpecialType type2, Vec2 pos2) {
    final affected = <Vec2>{};
    affected.addAll(getSpecialEffectPositions(pos1, type1));
    affected.addAll(getSpecialEffectPositions(pos2, type2));
    return SpecialComboResult(affectedPositions: affected.toList(), comboType: SpecialComboType.cross);
  }

  SpecialComboResult _handleStripedWrappedCombo(SpecialType type1, Vec2 pos1, SpecialType type2, Vec2 pos2) {
    final affected = <Vec2>{};
    affected.addAll(getSpecialEffectPositions(pos1, type1));
    affected.addAll(getSpecialEffectPositions(pos2, type2));
    return SpecialComboResult(affectedPositions: affected.toList(), comboType: SpecialComboType.simultaneous);
  }

  SpecialComboResult _handleWrappedWrappedCombo(Vec2 pos1, Vec2 pos2) {
    final affected = <Vec2>{};
    affected.addAll(getSpecialEffectPositions(pos1, SpecialType.wrapped));
    affected.addAll(getSpecialEffectPositions(pos2, SpecialType.wrapped));
    return SpecialComboResult(affectedPositions: affected.toList(), comboType: SpecialComboType.wrappedWrapped);
  }

  Set<Vec2> expandSpecials(List<Vec2> initialPositions, Map<Vec2, SpecialType> creationSpecials) {
    final toClear = <Vec2>{};
    final queue = <Vec2>[];

    for (final pos in initialPositions) {
      toClear.add(pos);
      queue.add(pos);
    }

    int depth = 0;
    while (queue.isNotEmpty && depth < maxSpecialExpansionDepth) {
      final pos = queue.removeAt(0);
      final tile = board.getTile(pos.x.toInt(), pos.y.toInt());

      if (tile == null || tile.specialType == SpecialType.none) continue;

      final effectPositions = getSpecialEffectPositions(pos, tile.specialType);
      for (final effectPos in effectPositions) {
        if (!toClear.contains(effectPos)) {
          toClear.add(effectPos);
          queue.add(effectPos);
        }
      }

      depth++;
    }

    return toClear;
  }

  List<Vec2> activateSpecialAt(Vec2 pos) {
    final col = pos.x.toInt();
    final row = pos.y.toInt();
    final tile = board.getTile(col, row);

    if (tile == null || tile.specialType == SpecialType.none) return [];

    final positions = getSpecialEffectPositions(pos, tile.specialType);
    board.setTile(col, row, null);
    return positions;
  }
}

enum SpecialComboType { boardWipe, bombStriped, bombWrapped, cross, simultaneous, wrappedWrapped }

class SpecialComboResult {
  final List<Vec2> affectedPositions;
  final SpecialComboType comboType;

  SpecialComboResult({required this.affectedPositions, required this.comboType});
}