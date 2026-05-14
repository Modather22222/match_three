// =============================================================================
// SAVE PROVIDER
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_game/models/save_data.dart';
import 'package:flutter_game/services/save_service.dart';

final saveServiceProvider = Provider<SaveService>((ref) {
  return SaveService();
});

class SaveDataProvider extends StateNotifier<SaveData> {
  final SaveService _saveService;

  SaveDataProvider(this._saveService) : super(_saveService.data);

  void reload() {
    state = _saveService.data;
  }
}

final saveDataProvider =
    StateNotifierProvider<SaveDataProvider, SaveData>((ref) {
  final service = ref.watch(saveServiceProvider);
  return SaveDataProvider(service);
});