import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/presentation/screens/home_screen.dart';
import 'package:task_manager/presentation/screens/task_detail_screen.dart';
import 'package:task_manager/presentation/screens/task_form_screen.dart';
import 'package:task_manager/presentation/screens/task_list_screen.dart';
import 'package:task_manager/presentation/screens/settings_screen.dart';
import 'package:task_manager/presentation/screens/statistics_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/tasks',
        builder: (context, state) => const TaskListScreen(),
      ),
      GoRoute(
        path: '/task/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TaskDetailScreen(taskId: id);
        },
      ),
      GoRoute(
        path: '/task-form',
        builder: (context, state) {
          final taskId = state.uri.queryParameters['taskId'];
          return TaskFormScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});