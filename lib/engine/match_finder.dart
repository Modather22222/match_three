// =============================================================================
// MATCH FINDER
// =============================================================================

import 'package:flutter_game/core/constants.dart';
import 'package:flutter_game/core/vector2d.dart';
import 'package:flutter_game/engine/board.dart';

/// Pure Dart match detection — no Flame or Flutter dependencies.
class MatchFinder {
  final Board board;

  MatchFinder(this.board);

  MatchInfo findMatches() {
    final horizontalRuns = _findHorizontalRuns();
    final verticalRuns = _findVerticalRuns();

    final allRuns = <List<Vec2>>[...horizontalRuns, ...verticalRuns];

    final specials = <Vec2, SpecialType>{};
    final consumedRunIndices = <int>{};

    _findWrappedMatches(allRuns, consumedRunIndices, specials);
    _findColorBombs(allRuns, consumedRunIndices, specials);
    _findStripedMatches(allRuns, consumedRunIndices, specials);

    final clearPositions = _collectClearPositions(allRuns, consumedRunIndices, specials);

    return MatchInfo(
      clearPositions: clearPositions,
      specials: specials,
    );
  }

  List<List<Vec2>> _findHorizontalRuns() {
    final runs = <List<Vec2>>[];

    for (int row = 0; row < boardRows; row++) {
      int runStart = 0;
      while (runStart < boardCols) {
        final startTile = board.getTile(runStart, row);
        if (startTile == null || startTile.isColorBomb) {
          runStart++;
          continue;
        }

        int runEnd = runStart + 1;
        while (runEnd < boardCols) {
          final nextTile = board.getTile(runEnd, row);
          if (nextTile == null || nextTile.tileType != startTile.tileType || nextTile.isColorBomb) {
            break;
          }
          runEnd++;
        }

        if (runEnd - runStart >= matchMinLength) {
          final positions = <Vec2>[];
          for (int c = runStart; c < runEnd; c++) {
            positions.add(Vec2(c.toDouble(), row.toDouble()));
          }
          runs.add(positions);
        }

        runStart = runEnd;
      }
    }
    return runs;
  }

  List<List<Vec2>> _findVerticalRuns() {
    final runs = <List<Vec2>>[];

    for (int col = 0; col < boardCols; col++) {
      int runStart = 0;
      while (runStart < boardRows) {
        final startTile = board.getTile(col, runStart);
        if (startTile == null || startTile.isColorBomb) {
          runStart++;
          continue;
        }

        int runEnd = runStart + 1;
        while (runEnd < boardRows) {
          final nextTile = board.getTile(col, runEnd);
          if (nextTile == null || nextTile.tileType != startTile.tileType || nextTile.isColorBomb) {
            break;
          }
          runEnd++;
        }

        if (runEnd - runStart >= matchMinLength) {
          final positions = <Vec2>[];
          for (int r = runStart; r < runEnd; r++) {
            positions.add(Vec2(col.toDouble(), r.toDouble()));
          }
          runs.add(positions);
        }

        runStart = runEnd;
      }
    }
    return runs;
  }

  void _findWrappedMatches(List<List<Vec2>> allRuns, Set<int> consumedRunIndices, Map<Vec2, SpecialType> specials) {
    for (int i = 0; i < allRuns.length; i++) {
      if (consumedRunIndices.contains(i)) continue;
      for (int j = i + 1; j < allRuns.length; j++) {
        if (consumedRunIndices.contains(j)) continue;

        final intersection = _runIntersection(allRuns[i], allRuns[j]);
        if (intersection != null) {
          specials[intersection] = SpecialType.wrapped;
          consumedRunIndices.add(i);
          consumedRunIndices.add(j);
          break;
        }
      }
    }
  }

  Vec2? _runIntersection(List<Vec2> run1, List<Vec2> run2) {
    final hRun = run1[0].y == run1.last.y ? run1 : run2;
    final vRun = run1[0].y == run1.last.y ? run2 : run1;

    final hRow = hRun[0].y;
    final vCol = vRun[0].x;

    final hColMin = hRun.fold<double>(double.infinity, (min, p) => p.x < min ? p.x : min);
    final hColMax = hRun.fold<double>(-1, (max, p) => p.x > max ? p.x : max);
    final vRowMin = vRun.fold<double>(double.infinity, (min, p) => p.y < min ? p.y : min);
    final vRowMax = vRun.fold<double>(-1, (max, p) => p.y > max ? p.y : max);

    if (vCol >= hColMin && vCol <= hColMax && hRow >= vRowMin && hRow <= vRowMax) {
      return Vec2(vCol, hRow);
    }
    return null;
  }

  void _findColorBombs(List<List<Vec2>> allRuns, Set<int> consumedRunIndices, Map<Vec2, SpecialType> specials) {
    for (int i = 0; i < allRuns.length; i++) {
      if (consumedRunIndices.contains(i)) continue;
      if (allRuns[i].length >= matchBombLength) {
        final bombPos = _preferredPosition(allRuns[i]);
        specials[bombPos] = SpecialType.colorBomb;
        consumedRunIndices.add(i);
      }
    }
  }

  void _findStripedMatches(List<List<Vec2>> allRuns, Set<int> consumedRunIndices, Map<Vec2, SpecialType> specials) {
    for (int i = 0; i < allRuns.length; i++) {
      if (consumedRunIndices.contains(i)) continue;
      if (allRuns[i].length == matchStripeLength) {
        final isHorizontal = allRuns[i][0].y == allRuns[i].last.y;
        final bombPos = _preferredPosition(allRuns[i]);
        specials[bombPos] = isHorizontal ? SpecialType.stripedH : SpecialType.stripedV;
        consumedRunIndices.add(i);
      }
    }
  }

  List<Vec2> _collectClearPositions(List<List<Vec2>> allRuns, Set<int> consumedRunIndices, Map<Vec2, SpecialType> specials) {
    final clearSet = <Vec2>{};
    for (int i = 0; i < allRuns.length; i++) {
      for (final pos in allRuns[i]) {
        if (!specials.containsKey(pos)) {
          clearSet.add(pos);
        }
      }
    }
    return clearSet.toList();
  }

  Vec2 _preferredPosition(List<Vec2> run) {
    final centerIdx = run.length ~/ 2;
    return Vec2(run[centerIdx].x, run[centerIdx].y);
  }

  bool hasColorBombAt(int col, int row) {
    final tile = board.getTile(col, row);
    return tile != null && tile.isColorBomb;
  }
}

class MatchInfo {
  final List<Vec2> clearPositions;
  final Map<Vec2, SpecialType> specials;

  MatchInfo({required this.clearPositions, required this.specials});

  bool get hasMatches => clearPositions.isNotEmpty || specials.isNotEmpty;
  int get clearCount => clearPositions.length;
}