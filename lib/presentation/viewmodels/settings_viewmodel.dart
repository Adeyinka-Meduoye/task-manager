import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/core/constants/app_strings.dart';
import 'package:task_manager/domain/providers/task_provider.dart';

class SettingsViewModel {
  Future<void> toggleTheme(WidgetRef ref, ThemeMode currentMode) async {
    final prefs = await SharedPreferences.getInstance();
    final newMode = currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    ref.read(themeModeProvider.notifier).state = newMode;
    await prefs.setString('themeMode', newMode.toString());
    debugPrint('Theme changed to: $newMode');
  }

  Future<bool> clearAllTasks(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.clearAllTasks),
        content: const Text(AppStrings.clearTasksConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.clearTasksButton),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repository = ref.read(taskRepositoryProvider);
      await repository.clearTasks();
      ref.invalidate(taskListProvider);
      debugPrint('All tasks cleared');
      return true;
    }
    return false;
  }
}

final settingsViewModelProvider = Provider<SettingsViewModel>((ref) => SettingsViewModel());

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);