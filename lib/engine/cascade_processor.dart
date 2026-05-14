// =============================================================================
// CASCADE PROCESSOR
// =============================================================================

import 'package:flutter_game/core/constants.dart';
import 'package:flutter_game/core/vector2d.dart';
import 'package:flutter_game/engine/board.dart';
import 'package:flutter_game/engine/match_finder.dart';
import 'package:flutter_game/engine/special_tile_logic.dart';
import 'package:flutter_game/models/tile_model.dart';

/// Manages the cascade loop: match → clear → gravity → refill → repeat.
class CascadeProcessor {
  final Board board;
  final MatchFinder matchFinder;
  final SpecialTileLogic specialLogic;

  CascadeProcessor({
    required this.board,
    MatchFinder? matchFinder,
    SpecialTileLogic? specialLogic,
  })  : matchFinder = matchFinder ?? MatchFinder(board),
        specialLogic = specialLogic ?? SpecialTileLogic(board);

  bool get isProcessing => _processing;
  bool _processing = false;

  int totalScore = 0;
  int totalCoins = 0;
  final List<CascadeStep> steps = [];

  List<CascadeStep> runCascade() {
    _processing = true;
    steps.clear();
    totalScore = 0;
    totalCoins = 0;

    int combo = 0;
    int depth = 0;

    while (depth < maxCascadeDepth) {
      final matchInfo = matchFinder.findMatches();

      if (!matchInfo.hasMatches) break;

      combo++;

      final expandedClearSet = specialLogic.expandSpecials(
        matchInfo.clearPositions,
        matchInfo.specials,
      ).toList();

      final matchScore = _calculateScore(expandedClearSet.length, combo);
      final coinEarned = expandedClearSet.length;
      totalScore += matchScore;
      totalCoins += coinEarned;

      steps.add(CascadeStep(
        combo: combo,
        clearedPositions: List<Vec2>.from(expandedClearSet),
        specialCreations: Map<Vec2, SpecialType>.from(matchInfo.specials),
        scoreEarned: matchScore,
        coinsEarned: coinEarned,
      ));

      _clearTiles(expandedClearSet);
      _createSpecialTiles(matchInfo.specials);
      final gravityMoves = _applyGravity();
      final refillMoves = _refillBoard();

      if (steps.isNotEmpty) {
        final lastStep = steps.last;
        lastStep
          ..gravityMoves.addAll(gravityMoves)
          ..refillMoves.addAll(refillMoves);
      }

      depth++;
    }

    _processing = false;
    return steps;
  }

  int _calculateScore(int clearedCount, int combo) {
    return clearedCount * basePoints * combo;
  }

  void _clearTiles(List<Vec2> positions) {
    for (final pos in positions) {
      final col = pos.x.toInt();
      final row = pos.y.toInt();
      if (board.isInBounds(col, row)) {
        board.setTile(col, row, null);
        _shiftColumnDown(col, row);
      }
    }
  }

  void _shiftColumnDown(int col, int clearedRow) {
    for (int r = clearedRow; r < boardRows - 1; r++) {
      final aboveTile = board.getTile(col, r + 1);
      if (aboveTile != null) {
        board.setTile(col, r, aboveTile.copyWith(gridRow: r));
      } else {
        board.setTile(col, r, null);
      }
    }
    board.setTile(col, boardRows - 1, null);
  }

  void _createSpecialTiles(Map<Vec2, SpecialType> specials) {
    for (final entry in specials.entries) {
      final col = entry.key.x.toInt();
      final row = entry.key.y.toInt();
      final existingTile = board.getTile(col, row);

      final newTile = TileModel(
        tileType: existingTile?.tileType ?? 0,
        gridCol: col,
        gridRow: row,
        specialType: entry.value,
      );
      board.setTile(col, row, newTile);
    }
  }

  List<GravityMove> _applyGravity() {
    final moves = <GravityMove>[];

    for (int col = 0; col < boardCols; col++) {
      int writePointer = 0;

      for (int row = 0; row < boardRows; row++) {
        final tile = board.getTile(col, row);
        if (tile != null) {
          if (row != writePointer) {
            final distance = row - writePointer;
            final duration = animGravityBase + animGravityPerRow * distance;

            moves.add(GravityMove(
              col: col,
              fromRow: row,
              toRow: writePointer,
              distance: distance,
              duration: duration,
            ));

            board.setTile(col, writePointer, tile.copyWith(gridRow: writePointer));
            board.setTile(col, row, null);
          }
          writePointer++;
        }
      }
    }

    return moves;
  }

  List<RefillMove> _refillBoard() {
    final moves = <RefillMove>[];

    for (int col = 0; col < boardCols; col++) {
      int emptyCount = 0;

      for (int row = boardRows - 1; row >= 0; row--) {
        if (board.getTile(col, row) == null) {
          emptyCount++;
        } else {
          break;
        }
      }

      for (int i = 0; i < emptyCount; i++) {
        final targetRow = boardRows - 1 - i;
        final dropDistance = emptyCount - i;
        final duration = animRefillBase + animRefillPerRow * dropDistance;
        final staggerDelay = animRefillStagger * i;

        final newTile = TileModel(
          tileType: _randomTileType(),
          gridCol: col,
          gridRow: targetRow,
          specialType: SpecialType.none,
        );

        board.setTile(col, targetRow, newTile);

        moves.add(RefillMove(
          col: col,
          row: targetRow,
          dropDistance: dropDistance,
          duration: duration,
          staggerDelay: staggerDelay,
          tileType: newTile.tileType,
        ));
      }
    }

    return moves;
  }

  int _randomTileType() {
    return DateTime.now().microsecondsSinceEpoch % numTileTypesFull;
  }

  void reset() {
    _processing = false;
    totalScore = 0;
    totalCoins = 0;
    steps.clear();
  }
}

class CascadeStep {
  final int combo;
  final List<Vec2> clearedPositions;
  final Map<Vec2, SpecialType> specialCreations;
  final int scoreEarned;
  final int coinsEarned;
  final List<GravityMove> gravityMoves = [];
  final List<RefillMove> refillMoves = [];

  CascadeStep({
    required this.combo,
    required this.clearedPositions,
    required this.specialCreations,
    required this.scoreEarned,
    required this.coinsEarned,
  });
}

class GravityMove {
  final int col;
  final int fromRow;
  final int toRow;
  final int distance;
  final double duration;

  GravityMove({
    required this.col,
    required this.fromRow,
    required this.toRow,
    required this.distance,
    required this.duration,
  });
}

class RefillMove {
  final int col;
  final int row;
  final int dropDistance;
  final double duration;
  final double staggerDelay;
  final int tileType;

  RefillMove({
    required this.col,
    required this.row,
    required this.dropDistance,
    required this.duration,
    required this.staggerDelay,
    required this.tileType,
  });
}

class CascadeCallbacks {
  final Function(List<Vec2>)? onBeforeClear;
  final Function(List<Vec2>)? onAfterClear;
  final Function(List<GravityMove>)? onGravity;
  final Function(List<RefillMove>)? onRefill;
  final Function(Map<Vec2, SpecialType>)? onSpecialsCreated;
  final Function(int combo, int score)? onCombo;

  CascadeCallbacks({
    this.onBeforeClear,
    this.onAfterClear,
    this.onGravity,
    this.onRefill,
    this.onSpecialsCreated,
    this.onCombo,
  });
}