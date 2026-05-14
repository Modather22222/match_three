// =============================================================================
// SETTINGS PROVIDER
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_game/services/save_service.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void toggleSound(bool value) {
    state = state.copyWith(soundEnabled: value);
  }

  void toggleMusic(bool value) {
    state = state.copyWith(musicEnabled: value);
  }

  void toggleNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }

  void loadFromSave(SaveService saveService) {
    state = SettingsState(
      soundEnabled: saveService.soundEnabled,
      musicEnabled: true,
      notificationsEnabled: true,
    );
  }
}

class SettingsState {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool notificationsEnabled;

  const SettingsState({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.notificationsEnabled = true,
  });

  SettingsState copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? notificationsEnabled,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});