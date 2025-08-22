import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/constants/app_colors.dart';
import 'package:task_manager/core/constants/app_sizes.dart';
import 'package:task_manager/core/constants/app_strings.dart';
import 'package:task_manager/presentation/viewmodels/settings_viewmodel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(settingsViewModelProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settingsScreenTitle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: AppSizes.iconSizeMedium),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        children: [
          ListTile(
            title: const Text(AppStrings.switchToDark),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                viewModel.toggleTheme(ref, themeMode);
              },
              activeColor: AppColors.primary,
            ),
          ),
          ListTile(
            title: const Text(AppStrings.clearAllTasks),
            trailing: Icon(
              Icons.delete_forever,
              color: Colors.red,
              size: AppSizes.iconSizeMedium,
            ),
            onTap: () async {
              final success = await viewModel.clearAllTasks(context, ref);
              if (success) {
                if (context.mounted){
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppStrings.tasksCleared)),
                );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}