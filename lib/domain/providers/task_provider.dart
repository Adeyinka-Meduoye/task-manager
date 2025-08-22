import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/data/repository/task_repository.dart';
import 'package:task_manager/domain/providers/category_provider.dart';

// Provider for the task repository
final taskRepositoryProvider = Provider<TaskRepository>((ref) => TaskRepository());

// Provider for the list of all tasks
final taskListProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  final tasks = await repository.getTasks();
  return tasks.map((task) {
    final categoryId = task.category?.id;
    final category = categoryId != null ? ref.watch(categoryProvider(categoryId)) : null;
    return task.copyWith(category: category);
  }).toList();
});

// Provider for a single task by ID
final taskProvider = Provider.family<TaskModel?, String>((ref, id) {
  final tasks = ref.watch(taskListProvider).valueOrNull ?? [];
  final task = tasks.firstWhere(
    (t) => t.id == id,
    orElse: () => TaskModel(id: '', title: '', priority: TaskPriority.low),
  );
  return task.id.isEmpty ? null : task;
});

// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for priority filter
final priorityFilterProvider = StateProvider<TaskPriority?>((ref) => null);

// Provider for category filter
final categoryFilterProvider = StateProvider<String?>((ref) => null);

// Provider for filtered task list
final filteredTaskListProvider = StateProvider<AsyncValue<List<TaskModel>>>((ref) {
  return ref.watch(taskListProvider);
});