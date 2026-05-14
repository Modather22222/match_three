// =============================================================================
// GAME SCREEN (Full Reactive — Final Version)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_game/game/match_game.dart';
import 'package:flutter_game/game/hammer_mode_overlay.dart';
import 'package:flutter_game/providers/game_state_provider.dart';
import 'package:flutter_game/providers/save_provider.dart';
import 'package:flutter_game/providers/shop_provider.dart';
import 'package:flutter_game/services/audio_service.dart';
import 'package:flutter_game/services/analytics_service.dart';
import 'package:flutter_game/widgets/hud_overlay.dart';
import 'package:flutter_game/widgets/popup_widget.dart';
import 'package:flutter_game/widgets/power_up_bar.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int level;

  const GameScreen({super.key, required this.level});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late MatchGame game;
  bool showWinPopup = false;
  bool showLosePopup = false;
  bool showDailyReward = false;
  int hammerStock = 0;
  int shuffleStock = 0;
  int extraMovesStock = 0;
  int starsEarned = 0;

  HammerModeOverlay? _hammerOverlay;

  @override
  void initState() {
    super.initState();
    game = MatchGame(currentLevel: widget.level);
    game.loadLevel(widget.level);

    game
      ..onScoreChanged = (score, target) {
        ref.read(gameStateProvider.notifier).updateScore(score);
      }
      ..onGameOver = (won, score) {
        _handleGameOver(won, score);
      }
      ..onCombo = (combo, scoreEarned) {
        AnalyticsService.instance.logEvent('combo_$combo', parameters: {'score_earned': scoreEarned});
        AudioService.instance.playCombo(combo);
      };

    AnalyticsService.instance.levelStart(widget.level);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDailyReward();
    });
  }

  @override
  void dispose() {
    game.reset();
    super.dispose();
  }

  void _handleGameOver(bool won, int finalScore) {
    final saveService = ref.read(saveServiceProvider);

    if (won) {
      starsEarned = game.stars;
      saveService.setLevelRecord(widget.level, starsEarned, finalScore);
      saveService.earnCoins(game.coins);
      AnalyticsService.instance.levelComplete(widget.level, starsEarned, finalScore, game.movesRemaining);
      AudioService.instance.playWin();
    } else {
      AudioService.instance.playLose();
      AnalyticsService.instance.levelFail(widget.level, finalScore, game.currentTargetScore);
      saveService.consumeLife();
    }

    ref.read(gameStateProvider.notifier).updateMoves(game.movesRemaining);

    setState(() {
      if (won) {
        showWinPopup = true;
      } else {
        showLosePopup = true;
      }
    });
  }

  void _checkDailyReward() {
    final saveService = ref.read(saveServiceProvider);
    final lastDaily = saveService.lastDaily;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastDaily != today) {
      setState(() {
        showDailyReward = true;
      });
    }
  }

  void _claimDailyReward() {
    final saveService = ref.read(saveServiceProvider);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    saveService.lastDaily = today;
    saveService.addLives(1);
    saveService.earnCoins(100);
    AnalyticsService.instance.logEvent('daily_reward_claimed');

    ref.read(saveDataProvider.notifier).reload();

    setState(() {
      showDailyReward = false;
    });
  }

  void _showRewardedAd() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🎁 Watching Ad...', style: TextStyle(color: Color(0xFFF0C040))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LinearProgressIndicator(
              value: null,
              backgroundColor: Color(0xFF2C3E50),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
            ),
            const SizedBox(height: 16),
            const Text('Reward: +5 moves', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                game.activateExtraMoves(5);
                ref.read(gameStateProvider.notifier).updateMoves(game.movesRemaining);
                setState(() => showLosePopup = false);
                AnalyticsService.instance.adWatched('rewarded', 'extra_moves');
              },
              child: const Text('SKIP (done)'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleHammerMode() {
    final enabled = !game.hammerMode;
    game.setHammerMode(enabled);

    if (enabled) {
      _hammerOverlay = HammerModeOverlay();
      game.world.add(_hammerOverlay!);
      game.inputHandler.onHammerTap = (col, row) {
        _onHammerTap(col, row);
      };
    } else {
      _hammerOverlay?.removeFromParent();
      _hammerOverlay = null;
      game.inputHandler.onHammerTap = null;
    }

    setState(() {});
  }

  void _onHammerTap(int col, int row) {
    if (hammerStock <= 0) {
      game.setHammerMode(false);
      _hammerOverlay?.removeFromParent();
      _hammerOverlay = null;
      setState(() {});
      return;
    }

    final shopNotifier = ref.read(shopProvider.notifier);
    shopNotifier.consume('hammer');
    hammerStock--;
    game.activateHammer(col, row);
    AudioService.instance.playSpecial();
    AnalyticsService.instance.logEvent('power_up_used', parameters: {'power_type': 'hammer', 'level_number': widget.level});

    if (hammerStock <= 0) {
      game.setHammerMode(false);
      _hammerOverlay?.removeFromParent();
      _hammerOverlay = null;
    }
    setState(() {});
  }

  void _activateShuffle() {
    final shopNotifier = ref.read(shopProvider.notifier);
    if (shuffleStock > 0) {
      shopNotifier.consume('shuffle');
      game.activateShuffle();
      AudioService.instance.playSpecial();
      AnalyticsService.instance.logEvent('power_up_used', parameters: {'power_type': 'shuffle', 'level_number': widget.level});
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final shopStock = ref.watch(shopProvider);
    hammerStock = shopStock['hammer'] ?? 0;
    shuffleStock = shopStock['shuffle'] ?? 0;
    extraMovesStock = shopStock['extra_moves'] ?? 0;

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),

          HUDOverlay(
            score: gameState.score,
            targetScore: gameState.targetScore,
            movesRemaining: gameState.movesRemaining,
            coins: gameState.coins,
            level: gameState.currentLevel,
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: PowerUpBar(
              hammers: hammerStock,
              shuffles: shuffleStock,
              extraMoves: extraMovesStock,
              onHammer: _toggleHammerMode,
              onShuffle: _activateShuffle,
              onExtraMoves: _showRewardedAd,
              onRestart: () {
                game.reset();
                game.loadLevel(widget.level);
              },
            ),
          ),

          if (showWinPopup)
            PopupWidget(
              title: 'LEVEL COMPLETE!',
              message: '⭐ $starsEarned Stars\nScore: $gameState.score / $gameState.targetScore',
              buttons: const ['RETRY', 'NEXT LEVEL', 'MENU'],
              onButtonPressed: (index) {
                setState(() {
                  showWinPopup = false;
                  starsEarned = 0;
                });
                switch (index) {
                  case 0:
                    game.reset();
                    game.loadLevel(widget.level);
                    break;
                  case 1:
                    final nextLevel = widget.level + 1;
                    game.reset();
                    game.loadLevel(nextLevel);
                    ref.read(gameStateProvider.notifier).updateLevel(nextLevel);
                    break;
                  case 2:
                    Navigator.pop(context);
                    break;
                }
              },
            ),

          if (showLosePopup)
            PopupWidget(
              title: 'OUT OF MOVES',
              message: 'Score: ${gameState.score} / ${gameState.targetScore}',
              buttons: extraMovesStock > 0
                  ? ['WATCH AD +5', 'RETRY', 'MENU']
                  : ['RETRY', 'MENU'],
              onButtonPressed: (index) {
                setState(() => showLosePopup = false);
                game.setHammerMode(false);
                _hammerOverlay?.removeFromParent();
                _hammerOverlay = null;
                switch (index) {
                  case 0:
                    if (extraMovesStock > 0) {
                      _showRewardedAd();
                    } else {
                      game.reset();
                      game.loadLevel(widget.level);
                    }
                    break;
                  case 1:
                    game.reset();
                    game.loadLevel(widget.level);
                    break;
                  case 2:
                    Navigator.pop(context);
                    break;
                }
              },
            ),

          if (showDailyReward) _buildDailyRewardPopup(),
        ],
      ),
    );
  }

  Widget _buildDailyRewardPopup() {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () {},
            child: Container(color: const Color(0xCC000000)),
          ),
        ),
        Center(
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0C040), width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉 DAILY REWARD', style: TextStyle(color: Color(0xFFF0C040), fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                const Text('Claim your daily bonus!', style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('+1 ❤️', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 16),
                    Text('+100 💰', style: TextStyle(fontSize: 20, color: Color(0xFFF0C040))),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _claimDailyReward,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    minimumSize: const Size(200, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('CLAIM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}