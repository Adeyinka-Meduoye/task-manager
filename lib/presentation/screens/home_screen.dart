import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/constants/app_strings.dart';
import 'package:task_manager/core/constants/app_sizes.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeScreenTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.push('/tasks'),
              child: const Text(AppStrings.viewTasksButton),
            ),
            SizedBox(height: AppSizes.marginMedium),
            ElevatedButton(
              onPressed: () => context.push('/statistics'),
              child: const Text(AppStrings.viewStatisticsButton),
            ),
            SizedBox(height: AppSizes.marginMedium),
            ElevatedButton(
              onPressed: () => context.push('/settings'),
              child: const Text(AppStrings.settingsButton),
            ),
            SizedBox(height: AppSizes.marginMedium),
            ElevatedButton(
              onPressed: () => context.push('/task-form'),
              child: const Text(AppStrings.addTaskButton),
            ),
          ],
        ),
      ),
    );
  }
}