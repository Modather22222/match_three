// =============================================================================
// MAIN FLAME GAME CLASS
// =============================================================================

import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/core/constants.dart';
import 'package:flutter_game/core/vector2d.dart';
import 'package:flutter_game/engine/board.dart';
import 'package:flutter_game/engine/cascade_processor.dart';
import 'package:flutter_game/engine/input_handler.dart';
import 'package:flutter_game/engine/match_finder.dart';
import 'package:flutter_game/engine/special_tile_logic.dart';
import 'package:flutter_game/models/tile_model.dart';
import 'package:flutter_game/game/score_popup_component.dart';
import 'package:flutter_game/game/tile_component.dart';
import 'package:flutter_game/game/background_component.dart';
import 'package:flutter_game/game/board_component.dart';

typedef ScoreCallback = void Function(int score, int target);
typedef GameOverCallback = void Function(bool won, int score);
typedef ComboCallback = void Function(int combo, int score);

class MatchGame extends FlameGame {
  late Board board;
  late MatchFinder matchFinder;
  late SpecialTileLogic specialLogic;
  late CascadeProcessor cascadeProcessor;
  late InputHandler inputHandler;

  late BoardComponent boardComponent;
  late BackgroundComponent backgroundComponent;

  int score = 0;
  int coins = 500;
  int movesRemaining = 30;
  int currentLevel = 1;
  bool processing = false;
  bool _boardEntered = false;
  bool _onLoadCompleted = false;
  int? _pendingLevel;

  final _loadCompleter = Completer<void>();
  Future<void> get onLoadCompletedFuture => _loadCompleter.future;

  ScoreCallback? onScoreChanged;
  GameOverCallback? onGameOver;
  ComboCallback? onCombo;

  int _targetScore = 300;

  MatchGame({
    this.score = 0,
    this.coins = 500,
    this.movesRemaining = 30,
    this.currentLevel = 1,
  });

  int get stars {
    if (_targetScore == 0) return 0;
    final ratio = score / _targetScore;
    if (ratio < 1.0) return 0;
    if (ratio < 1.5) return 1;
    if (ratio < 2.0) return 2;
    return 3;
  }

  int get targetScore => _targetScore;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;

    board = Board(numTileTypes: _numTypesForLevel(currentLevel));
    matchFinder = MatchFinder(board);
    specialLogic = SpecialTileLogic(board);
    cascadeProcessor = CascadeProcessor(
      board: board,
      matchFinder: matchFinder,
      specialLogic: specialLogic,
    );
    inputHandler = InputHandler(board);

    boardComponent = BoardComponent();
    backgroundComponent =
        BackgroundComponent(Vector2(horizontalResolution, verticalResolution));

    world.add(backgroundComponent);
    world.add(boardComponent);

    if (_pendingLevel != null) {
      _applyLevel(_pendingLevel!);
      _pendingLevel = null;
    } else {
      board.generateBoard();
      assert(!matchFinder.findMatches().hasMatches, 'Board has initial matches!');
    }

    _spawnTileComponents();
    _animateBoardEntrance();
    _notifyScoreChanged();
    _onLoadCompleted = true;
    _loadCompleter.complete();
  }

  int _numTypesForLevel(int level) =>
      level <= 2 ? numTileTypesTutorial : numTileTypesFull;

  void _applyLevel(int levelNumber) {
    currentLevel = levelNumber;
    movesRemaining = (30 - (levelNumber - 1)).clamp(15, 30);
    _targetScore = 300 + (levelNumber - 1) * 200;
    score = 0;
    coins = 0;
    board.numTileTypes = levelNumber <= 2 ? 4 : 5;
    board.generateBoard();
    cascadeProcessor.reset();
  }

  void _spawnTileComponents() {
    _clearTileComponents();
    for (int c = 0; c < boardCols; c++) {
      for (int r = 0; r < boardRows; r++) {
        final tile = board.getTile(c, r);
        if (tile != null) {
          final position = board.gridToWorld(c, r);
          final tileComp = TileComponent(
            model: tile,
            position: Vector2(position.x, position.y),
            size: Vector2(tileSize.toDouble(), tileSize.toDouble()),
          );
          tileComp.tileOpacity = 0.0;
          tileComp.add(
            OpacityEffect.to(
              1.0,
              EffectController(duration: 0.3),
            ),
          );
          world.add(tileComp);
        }
      }
    }
  }

  void _clearTileComponents() {
    for (final child in world.children.whereType<TileComponent>().toList()) {
      child.removeFromParent();
    }
  }

  void _refreshTileComponents() {
    _clearTileComponents();
    _spawnTileComponents();
  }

  void _animateBoardEntrance() {
    _boardEntered = false;

    final tileComponents = <TileComponent>[];
    for (final child in world.children) {
      if (child is TileComponent) {
        tileComponents.add(child);
      }
    }

    if (tileComponents.isEmpty) {
      _boardEntered = true;
      return;
    }

    for (var i = 0; i < tileComponents.length; i++) {
      final comp = tileComponents[i];
      final delay = animBoardEntry * (i / tileComponents.length) * 0.5;
      Future.delayed(Duration(milliseconds: (delay * 1000).round()), () {
        if (comp.isMounted) {
          comp.add(
            SequenceEffect([
              ScaleEffect.by(
                Vector2(0.7, 0.7),
                EffectController(duration: animBoardEntry * 0.5, curve: Curves.easeOutBack),
              ),
            ]),
          );
        }
      });
    }

    Future.delayed(Duration(milliseconds: (animBoardEntry * 1000).round() + 200), () {
      _boardEntered = true;
    });
  }

  Vector2? handlePointerDown(double worldX, double worldY) {
    final result = inputHandler.onPointerDown(worldX, worldY);
    if (result == null) return null;
    return Vector2(result.x, result.y);
  }

  SwapResult? handlePointerMove(double worldX, double worldY) {
    return inputHandler.onPointerMove(worldX, worldY);
  }

  SwapResult? handlePointerUp(double worldX, double worldY) {
    return inputHandler.onPointerUp(worldX, worldY);
  }

  void setHammerMode(bool enabled) => inputHandler.hammerMode = enabled;
  bool get hammerMode => inputHandler.hammerMode;

  Future<SwapResult?> executeSwap(int col1, int row1, int col2, int row2) async {
    if (processing || !_boardEntered) return null;

    final result = board.performSwap(col1, row1, col2, row2);
    if (!result.success) return result;

    final matchInfo = matchFinder.findMatches();
    final tile1 = board.getTile(col1, row1);
    final tile2 = board.getTile(col2, row2);
    final isBombSwap =
        tile1 != null && tile1.isColorBomb || tile2 != null && tile2.isColorBomb;

    if (!matchInfo.hasMatches && !isBombSwap) {
      board.performSwap(col1, row1, col2, row2);
      _refreshTileComponents();
      return SwapResult.failed('no match');
    }

    movesRemaining--;
    processing = true;
    inputHandler.isProcessing = true;

    await _processCascadeWithDelay();

    _refreshTileComponents();

    processing = false;
    inputHandler.isProcessing = false;
    _notifyScoreChanged();
    _checkGameOver();

    return result;
  }

  Future<void> _processCascadeWithDelay() async {
    int stepDelay = 0;
    final steps = cascadeProcessor.runCascade();

    for (final step in steps) {
      score += step.scoreEarned;
      coins += step.coinsEarned;
      onCombo?.call(step.combo, step.scoreEarned);
      _refreshTileComponents();
      _spawnScorePopup(step);
      await Future.delayed(Duration(
        milliseconds: (stepDelay + animClear * 1000).round(),
      ));
      stepDelay += (animClear * 1000).round();
    }
  }

  void _spawnScorePopup(CascadeStep step) {
    final centerX = boardOffsetX + (boardCols * tileSize) / 2;
    final centerY = boardOffsetY + (boardRows * tileSize) / 2;

    if (step.combo >= 2) {
      world.add(ComboPopupComponent(
        position: Vector2(centerX, centerY),
        text: 'COMBO x${step.combo}!',
      ));
    }

    world.add(ScorePopupComponent(
      position: Vector2(centerX, centerY + 30),
      text: '+${step.scoreEarned}',
      baseFontSize: scorePopupBaseSize + scorePopupComboIncrement * (step.combo - 1),
    ));
  }

  void _consumeMove() => movesRemaining--;
  void _notifyScoreChanged() => onScoreChanged?.call(score, targetScore);

  void _checkGameOver() {
    if (score >= _targetScore) {
      _onLevelCompleted();
    } else if (movesRemaining <= 0) {
      _onLevelFailed();
    }
  }

  void _onLevelCompleted() => onGameOver?.call(true, score);
  void _onLevelFailed() => onGameOver?.call(false, score);

  void loadLevel(int levelNumber) {
    if (!_onLoadCompleted) {
      _pendingLevel = levelNumber;
      return;
    }
    _applyLevel(levelNumber);
    _spawnTileComponents();
    _animateBoardEntrance();
    _notifyScoreChanged();
  }

  void activateHammer(int col, int row) {
    if (board.isInBounds(col, row)) {
      final tile = board.getTile(col, row);
      board.setTile(col, row, null);
      if (tile != null && tile.isSpecial) {
        cascadeProcessor.totalScore += basePoints * 2;
        cascadeProcessor.totalCoins += 2;
      }
      _refreshTileComponents();
      cascadeProcessor.runCascade();
      score += cascadeProcessor.totalScore;
      coins += cascadeProcessor.totalCoins;
      _consumeMove();
      _notifyScoreChanged();
      _checkGameOver();
    }
  }

  Future<void> activateShuffle() async {
    final rng = Random();
    final originalTiles = <TileModel>[];
    final positions = <Vec2>[];

    for (int c = 0; c < boardCols; c++) {
      for (int r = 0; r < boardRows; r++) {
        final tile = board.getTile(c, r);
        if (tile != null) {
          originalTiles.add(tile);
          positions.add(Vec2(c.toDouble(), r.toDouble()));
        }
      }
    }

    final types = originalTiles.map((t) => t.tileType).toList();
    types.shuffle(rng);

    for (var i = 0; i < originalTiles.length; i++) {
      board.setTile(positions[i].x.toInt(), positions[i].y.toInt(),
          originalTiles[i].copyWith(tileType: types[i]));
    }

    int attempts = 0;
    while (matchFinder.findMatches().hasMatches && attempts < 50) {
      final matchInfo = matchFinder.findMatches();
      for (final pos in matchInfo.clearPositions) {
        board.setTile(
          pos.x.toInt(),
          pos.y.toInt(),
          TileModel(
            tileType: rng.nextInt(board.numTileTypes),
            gridCol: pos.x.toInt(),
            gridRow: pos.y.toInt(),
          ),
        );
      }
      attempts++;
    }

    _refreshTileComponents();
    _consumeMove();
    _notifyScoreChanged();
    _checkGameOver();
  }

  void activateExtraMoves(int additionalMoves) => movesRemaining += additionalMoves;
  bool isTileSelected(int col, int row) => inputHandler.isSelected(col, row);
  void clearSelection() => inputHandler.clearSelection();

void reset() {
    inputHandler.reset();
    cascadeProcessor.reset();
    score = 0;
    coins = 0;
    processing = false;
    _boardEntered = false;
    _onLoadCompleted = false;
    _clearTileComponents();
  }

  int get currentTargetScore => _targetScore;
}