import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/core/constants/app_strings.dart';
import 'package:task_manager/core/constants/app_sizes.dart';
import 'package:task_manager/domain/providers/task_provider.dart';
import 'package:task_manager/presentation/viewmodels/statistics_viewmodel.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(statisticsViewModelProvider);
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.statisticsScreenTitle),
      ),
      body: tasksAsync.when(
        data: (tasks) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.taskOverview,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: AppSizes.marginMedium),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    children: [
                      Text('${AppStrings.totalTasks}: ${viewModel.getTotalTasks(tasks)}'),
                      Text('${AppStrings.completedTasks}: ${viewModel.getCompletedTasks(tasks)}'),
                      Text('${AppStrings.incompleteTasks}: ${viewModel.getIncompleteTasks(tasks)}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSizes.marginLarge),
              Text(
                AppStrings.completionStatus,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: AppSizes.marginMedium),
              SizedBox(
                height: AppSizes.chartHeight,
                child: viewModel.getCompletionChart(),
              ),
              SizedBox(height: AppSizes.marginLarge),
              Text(
                AppStrings.tasksByPriority,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: AppSizes.marginMedium),
              SizedBox(
                height: AppSizes.chartHeight,
                child: viewModel.getPriorityChart(),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('${AppStrings.errorMessage}: $error')),
      ),
    );
  }
}