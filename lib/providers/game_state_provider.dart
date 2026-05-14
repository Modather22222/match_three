// =============================================================================
// GAME STATE PROVIDER
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(const GameState());

  void updateScore(int newScore) {
    state = state.copyWith(score: newScore);
  }

  void updateCoins(int newCoins) {
    state = state.copyWith(coins: newCoins);
  }

  void updateLevel(int level) {
    state = state.copyWith(currentLevel: level);
  }

  void updateMoves(int moves) {
    state = state.copyWith(movesRemaining: moves);
  }

  void setProcessing(bool processing) {
    state = state.copyWith(isProcessing: processing);
  }

  void reset() {
    state = const GameState();
  }
}

class GameState {
  final int score;
  final int coins;
  final int currentLevel;
  final int movesRemaining;
  final bool isProcessing;

  const GameState({
    this.score = 0,
    this.coins = 500,
    this.currentLevel = 1,
    this.movesRemaining = 30,
    this.isProcessing = false,
  });

  static const defaults = GameState();

  GameState copyWith({
    int? score,
    int? coins,
    int? currentLevel,
    int? movesRemaining,
    bool? isProcessing,
  }) {
    return GameState(
      score: score ?? this.score,
      coins: coins ?? this.coins,
      currentLevel: currentLevel ?? this.currentLevel,
      movesRemaining: movesRemaining ?? this.movesRemaining,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  int get targetScore => 300 + (currentLevel - 1) * 200;
  double get progress => targetScore > 0 ? (score / targetScore).clamp(0.0, 1.0) : 0.0;

  int get stars {
    if (targetScore == 0) return 0;
    final ratio = score / targetScore;
    if (ratio < 1.0) return 0;
    if (ratio < 1.5) return 1;
    if (ratio < 2.0) return 2;
    return 3;
  }
}

final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});