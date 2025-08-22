import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/core/constants/app_strings.dart';
import 'package:task_manager/core/router/app_router.dart';
import 'package:task_manager/core/theme/app_theme.dart';
import 'package:task_manager/presentation/viewmodels/settings_viewmodel.dart';

class TaskManagerApp extends ConsumerWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppStrings.appTitle,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}