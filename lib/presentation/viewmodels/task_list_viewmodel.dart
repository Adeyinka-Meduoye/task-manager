import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/core/constants/app_strings.dart';
import 'package:task_manager/core/constants/app_sizes.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/domain/providers/task_provider.dart';
import 'package:task_manager/domain/providers/category_provider.dart' hide taskRepositoryProvider;

class TaskListViewModel {
  void filterTasks(WidgetRef ref) {
    final tasks = ref.read(taskListProvider).valueOrNull ?? [];
    final query = ref.read(searchQueryProvider);
    final priority = ref.read(priorityFilterProvider);
    final categoryId = ref.read(categoryFilterProvider);

    final filteredTasks = tasks.where((task) {
      final matchesQuery = query.isEmpty ||
          task.title.toLowerCase().contains(query.toLowerCase()) ||
          (task.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
      final matchesPriority = priority == null || task.priority == priority;
      final matchesCategory = categoryId == null || task.category?.id == categoryId;
      return matchesQuery && matchesPriority && matchesCategory;
    }).toList();

    ref.read(filteredTaskListProvider.notifier).state = AsyncData(filteredTasks);
  }

  void toggleTaskCompletion(WidgetRef ref, String taskId) async {
    final tasks = ref.read(taskListProvider).valueOrNull ?? [];
    final task = tasks.firstWhere((t) => t.id == taskId, orElse: () => TaskModel(id: '', title: '', priority: TaskPriority.low));
    if (task.id.isNotEmpty) {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      final repository = ref.read(taskRepositoryProvider);
      await repository.updateTask(updatedTask);
      ref.invalidate(taskListProvider);
    }
  }

  void deleteTask(WidgetRef ref, String taskId) async {
    final repository = ref.read(taskRepositoryProvider);
    await repository.deleteTask(taskId);
    ref.invalidate(taskListProvider);
  }

  void showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.filterTasksTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<TaskPriority?>(
                value: ref.watch(priorityFilterProvider),
                hint: const Text(AppStrings.selectPriorityHint),
                isExpanded: true,
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text(AppStrings.allPrioritiesOption)),
                  ...TaskPriority.values.map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority.toString().split('.').last),
                      )),
                ],
                onChanged: (value) {
                  ref.read(priorityFilterProvider.notifier).state = value;
                  filterTasks(ref);
                },
              ),
              SizedBox(height: AppSizes.marginMedium),
              DropdownButton<String?>(
                value: ref.watch(categoryFilterProvider),
                hint: const Text(AppStrings.selectCategoryHint),
                isExpanded: true,
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text(AppStrings.allCategoriesOption)),
                  ...ref.watch(categoryListProvider).valueOrNull?.map((category) =>
                      DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      )) ??
                      [],
                ],
                onChanged: (value) {
                  ref.read(categoryFilterProvider.notifier).state = value;
                  filterTasks(ref);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(priorityFilterProvider.notifier).state = null;
              ref.read(categoryFilterProvider.notifier).state = null;
              filterTasks(ref);
              Navigator.pop(context);
            },
            child: const Text(AppStrings.clearFiltersButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.closeButton),
          ),
        ],
      ),
    );
  }
}

final taskListViewModelProvider = Provider<TaskListViewModel>((ref) => TaskListViewModel());