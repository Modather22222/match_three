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

/// Callback type for game events
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

  // Callbacks — wired by GameScreen
  ScoreCallback? onScoreChanged;
  GameOverCallback? onGameOver;
  ComboCallback? onCombo;

  MatchGame({
    this.score = 0,
    this.coins = 500,
    this.movesRemaining = 30,
    this.currentLevel = 1,
  });

  int get stars {
    final target = currentTargetScore;
    if (target == 0) return 0;
    final ratio = score / target;
    if (ratio < 1.0) return 0;
    if (ratio < 1.5) return 1;
    if (ratio < 2.0) return 2;
    return 3;
  }

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

    board.generateBoard();
    assert(!matchFinder.findMatches().hasMatches, 'Board has initial matches!');

    _animateBoardEntrance();
  }

  int _numTypesForLevel(int level) =>
      level <= 2 ? numTileTypesTutorial : numTileTypesFull;

  // ──── Board Entrance Animation ────

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
      comp.tileOpacity = 0;
      final delay = animBoardEntry * (i / tileComponents.length) * 0.5;
      Future.delayed(Duration(milliseconds: (delay * 1000).round()), () {
        if (comp.isMounted) {
          comp.add(
            SequenceEffect([
              OpacityEffect.to(
                1.0,
                EffectController(duration: animBoardEntry * 0.5),
              ),
              ScaleEffect.by(
                Vector2(0.7, 0.7),
                EffectController(
                  duration: animBoardEntry * 0.5,
                  curve: Curves.easeOutBack,
                ),
              ),
            ]),
          );
        }
      });
    }

    Future.delayed(Duration(milliseconds: (animBoardEntry * 1000).round() + 200),
        () {
      _boardEntered = true;
    });
  }

  // ──── Input handling ────

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

  void setHammerMode(bool enabled) {
    inputHandler.hammerMode = enabled;
  }

  bool get hammerMode => inputHandler.hammerMode;

  // ──── Swap Execution ────

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
      return SwapResult.failed('no match');
    }

    _consumeMove();
    processing = true;
    inputHandler.isProcessing = true;

    await _processCascadeWithDelay();

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

      // Spawn score popup at board center for each combo step
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
      final comboText = 'COMBO x${step.combo}!';
      world.add(ComboPopupComponent(
        position: Vector2(centerX, centerY),
        text: comboText,
      ));
    }

    // Always show score popup for the earned points
    final scoreText = step.combo <= 1 ? '+${step.scoreEarned}' : '+${step.scoreEarned}';
    world.add(ScorePopupComponent(
      position: Vector2(centerX, centerY + 30),
      text: scoreText,
      baseFontSize: scorePopupBaseSize + scorePopupComboIncrement * (step.combo - 1),
    ));
  }

  void _consumeMove() {
    movesRemaining--;
  }

  void _notifyScoreChanged() {
    onScoreChanged?.call(score, currentTargetScore);
  }

  void _checkGameOver() {
    final target = currentTargetScore;
    if (score >= target) {
      _onLevelCompleted();
    } else if (movesRemaining <= 0) {
      _onLevelFailed();
    }
  }

  void _onLevelCompleted() {
    onGameOver?.call(true, score);
  }

  void _onLevelFailed() {
    onGameOver?.call(false, score);
  }

  int get currentTargetScore => 300 + (currentLevel - 1) * 200;

  void loadLevel(int levelNumber) {
    currentLevel = levelNumber;
    movesRemaining = (30 - (levelNumber - 1)).clamp(15, 30);
    score = 0;
    coins = 0;
    board.numTileTypes = levelNumber <= 2 ? 4 : 5;
    board.generateBoard();
    cascadeProcessor.reset();
    _boardEntered = false;
    _animateBoardEntrance();
    _notifyScoreChanged();
  }

  // ──── Power-ups ────

  void activateHammer(int col, int row) {
    if (board.isInBounds(col, row)) {
      final tile = board.getTile(col, row);
      board.setTile(col, row, null);
      if (tile != null && tile.isSpecial) {
        cascadeProcessor.totalScore += basePoints * 2;
        cascadeProcessor.totalCoins += 2;
      }
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
      final pos = positions[i];
      board.setTile(
        pos.x.toInt(),
        pos.y.toInt(),
        originalTiles[i].copyWith(tileType: types[i]),
      );
    }

    int attempts = 0;
    while (matchFinder.findMatches().hasMatches && attempts < 50) {
      final matchInfo = matchFinder.findMatches();
      for (final pos in matchInfo.clearPositions) {
        final c = pos.x.toInt();
        final r = pos.y.toInt();
        board.setTile(c, r, TileModel(
          tileType: rng.nextInt(board.numTileTypes),
          gridCol: c,
          gridRow: r,
        ));
      }
      attempts++;
    }

    _consumeMove();
    _notifyScoreChanged();
    _checkGameOver();
  }

  void activateExtraMoves(int additionalMoves) {
    movesRemaining += additionalMoves;
  }

  bool isTileSelected(int col, int row) => inputHandler.isSelected(col, row);
  void clearSelection() => inputHandler.clearSelection();

  void reset() {
    inputHandler.reset();
    cascadeProcessor.reset();
    score = 0;
    coins = 0;
    processing = false;
    _boardEntered = false;
    // Clean up all tile components
    for (final child in world.children.whereType<TileComponent>().toList()) {
      child.removeFromParent();
    }
  }
}