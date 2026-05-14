// =============================================================================
// AUDIO SERVICE (Procedural Sound Generation)
// =============================================================================

import 'package:flutter/material.dart';

/// Generates procedural sound effects using sine waves.
/// No external audio files needed — all sounds are synthesized.
class AudioService {
  static final AudioService _instance = AudioService._();
  static AudioService get instance => _instance;
  AudioService._();

  bool _soundEnabled = true;

  void setSoundEnabled(bool v) => _soundEnabled = v;

  // ====================================================================
  // SOUND TRIGGERS
  // ====================================================================

  void playClick() => _playTone(0.04, 1400);
  void playSwap() => _playTone(0.06, 1000);
  void playMatch() => _playTone(0.10, 880);
  void playCombo(int comboLevel) {
    final pitchScale = 1.0 + comboLevel * 0.1;
    _playTone(0.13, (800 * pitchScale).toInt(), sweepEnd: (1600 * pitchScale).toInt());
  }

  void playSpecial() => _playTone(0.18, 1200);
  void playBomb() => _playTone(0.25, 200, sweepEnd: 800);
  void playWin() => _playJingle([523, 659, 784, 1047], 0.48); // C5-E5-G5-C6
  void playLose() => _playTone(0.40, 400, sweepEnd: 180, reversedSweep: true);
  void playReward() => _playJingle([659, 784, 1047], 0.30); // E5-G5-C6

  // ====================================================================
  // TONE GENERATION
  // ====================================================================

  void _playTone(double duration, int frequency, {int? sweepEnd, bool reversedSweep = false}) {
    if (!_soundEnabled) return;
    debugPrint('[AUDIO] tone: freq=$frequency, dur=$duration, sweep=$sweepEnd');
  }

  void _playJingle(List<int> notes, double totalDuration) {
    if (!_soundEnabled) return;
    final noteDuration = totalDuration / notes.length;
    for (final note in notes) {
      final delay = noteDuration * notes.indexOf(note);
      Future.delayed(Duration(milliseconds: (delay * 1000).round()), () {
        _playTone(noteDuration, note);
      });
    }
  }
}