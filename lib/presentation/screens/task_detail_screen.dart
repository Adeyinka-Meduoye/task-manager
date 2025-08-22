import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/core/constants/app_colors.dart';
import 'package:task_manager/core/constants/app_strings.dart';
import 'package:task_manager/core/constants/app_sizes.dart';
import 'package:task_manager/domain/providers/task_provider.dart';
import 'package:task_manager/presentation/widgets/category_tag.dart';
import 'package:task_manager/presentation/widgets/priority_indicator.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskProvider(taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.taskDetailScreenTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, size: AppSizes.iconSizeMedium),
            onPressed: () => context.go('/task-form?taskId=$taskId'),
          ),
        ],
      ),
      body: task == null
          ? const Center(child: Text(AppStrings.taskNotFound))
          : Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              decoration:
                                  task.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                      ),
                      SizedBox(height: AppSizes.marginMedium),
                      if (task.description != null)
                        Text(
                          task.description!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      if (task.description != null) SizedBox(height: AppSizes.marginMedium),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: AppColors.primary, size: AppSizes.iconSizeMedium),
                          SizedBox(width: AppSizes.marginSmall),
                          Text(
                            task.dueDate != null
                                ? '${AppStrings.dueDateLabel}: ${DateFormat.yMMMd().format(task.dueDate!)}'
                                : 'No due date',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.marginMedium),
                      Row(
                        children: [
                          Icon(Icons.priority_high,
                              color: AppColors.primary, size: AppSizes.iconSizeMedium),
                          SizedBox(width: AppSizes.marginSmall),
                          PriorityIndicator(priority: task.priority),
                        ],
                      ),
                      SizedBox(height: AppSizes.marginMedium),
                      if (task.category != null)
                        Row(
                          children: [
                            Icon(Icons.label,
                                color: AppColors.primary, size: AppSizes.iconSizeMedium),
                            SizedBox(width: AppSizes.marginSmall),
                            CategoryTag(category: task.category!),
                          ],
                        ),
                      SizedBox(height: AppSizes.marginMedium),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: AppSizes.iconSizeMedium,
                          ),
                          SizedBox(width: AppSizes.marginSmall),
                          Text(
                            task.isCompleted
                                ? AppStrings.completedTasks
                                : AppStrings.incompleteTasks,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: task.isCompleted ? Colors.green : Colors.red,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}