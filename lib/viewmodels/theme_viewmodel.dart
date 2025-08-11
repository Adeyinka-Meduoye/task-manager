import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class ThemeViewModel extends StateNotifier<bool> {
  final StorageService _storageService;

  ThemeViewModel(this._storageService) : super(false) {
    loadTheme();
  }

  Future<void> loadTheme() async {
    state = await _storageService.loadTheme();
  }

  void toggleTheme() {
    state = !state;
    _storageService.saveTheme(state);
  }
}

final themeViewModelProvider = StateNotifierProvider<ThemeViewModel, bool>((ref) {
  return ThemeViewModel(StorageService());
});