// =============================================================================
// TILE MODEL
// =============================================================================

import 'package:flutter_game/core/constants.dart';
import 'package:flutter_game/core/vector2d.dart';

/// Represents the data for a single tile on the board.
class TileModel {
  final int tileType; // 0-based color index
  Vec2 gridPos;
  SpecialType specialType;

  TileModel({
    required this.tileType,
    required int gridCol,
    required int gridRow,
    this.specialType = SpecialType.none,
  })  : gridPos = Vec2(gridCol.toDouble(), gridRow.toDouble());

  int get gridCol => gridPos.x.toInt();
  int get gridRow => gridPos.y.toInt();

  TileModel copyWith({
    int? tileType,
    int? gridCol,
    int? gridRow,
    SpecialType? specialType,
  }) {
    return TileModel(
      tileType: tileType ?? this.tileType,
      gridCol: gridCol ?? this.gridCol,
      gridRow: gridRow ?? this.gridRow,
      specialType: specialType ?? this.specialType,
    );
  }

  bool get isSpecial => specialType != SpecialType.none;
  bool get isColorBomb => specialType == SpecialType.colorBomb;
  bool get isStriped =>
      specialType == SpecialType.stripedH || specialType == SpecialType.stripedV;
  bool get isWrapped => specialType == SpecialType.wrapped;

  @override
  String toString() =>
      'TileModel(type:$tileType, pos:($gridCol,$gridRow), special:$specialType)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileModel &&
          runtimeType == other.runtimeType &&
          tileType == other.tileType &&
          gridCol == other.gridCol &&
          gridRow == other.gridRow &&
          specialType == other.specialType;

  @override
  int get hashCode =>
      tileType.hashCode ^ gridCol.hashCode ^ gridRow.hashCode ^ specialType.hashCode;
}

TileModel createRandomTile(int col, int row, int numTypes) {
  return TileModel(
    tileType: DateTime.now().microsecondsSinceEpoch % numTypes,
    gridCol: col,
    gridRow: row,
  );
}