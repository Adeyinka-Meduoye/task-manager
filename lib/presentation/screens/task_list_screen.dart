import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/constants/app_strings.dart';
import 'package:task_manager/core/constants/app_sizes.dart';
import 'package:task_manager/domain/providers/task_provider.dart';
import 'package:task_manager/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:task_manager/presentation/widgets/search_bar.dart';
import 'package:task_manager/presentation/widgets/task_card.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(taskListViewModelProvider);
    final tasksAsync = ref.watch(filteredTaskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.taskListScreenTitle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: AppSizes.iconSizeMedium),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, size: AppSizes.iconSizeMedium),
            onPressed: () => viewModel.showFilterDialog(context, ref),
          ),
          IconButton(
            icon: Icon(Icons.add, size: AppSizes.iconSizeMedium),
            onPressed: () => context.push('/task-form'),
          ),
        ],
      ),
      body: Column(
        children: [
          CustomSearchBar(
            onQueryChanged: (query) {
              ref.read(searchQueryProvider.notifier).state = query;
              viewModel.filterTasks(ref);
            },
          ),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) => tasks.isEmpty
                  ? const Center(child: Text(AppStrings.noTasks))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskCard(
                          task: task,
                          onToggleComplete: () =>
                              viewModel.toggleTaskCompletion(ref, task.id),
                          onDelete: () => viewModel.deleteTask(ref, task.id),
                          onTap: () => context.push('/task/${task.id}'),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('${AppStrings.errorMessage}: $error')),
            ),
          ),
        ],
      ),
    );
  }
}