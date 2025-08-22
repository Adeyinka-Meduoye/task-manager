import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/constants/app_strings.dart';
import 'package:task_manager/core/constants/app_sizes.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/domain/providers/category_provider.dart';
import 'package:task_manager/presentation/viewmodels/task_form_viewmodel.dart';

class TaskFormScreen extends ConsumerWidget {
  final String? taskId;

  const TaskFormScreen({super.key, this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(taskFormViewModelProvider(taskId));
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          taskId == null
              ? AppStrings.taskFormScreenTitleAdd
              : AppStrings.taskFormScreenTitleEdit,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: AppSizes.iconSizeMedium),
          onPressed: () => context.go('/tasks'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        child: Form(
          key: viewModel.formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: viewModel.title,
                  decoration: const InputDecoration(
                    labelText: AppStrings.titleLabel,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? AppStrings.titleRequired
                      : null,
                  onChanged: viewModel.setTitle,
                ),
                SizedBox(height: AppSizes.marginMedium),
                TextFormField(
                  initialValue: viewModel.description,
                  decoration: const InputDecoration(
                    labelText: AppStrings.descriptionLabel,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: viewModel.setDescription,
                ),
                SizedBox(height: AppSizes.marginMedium),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: AppStrings.dueDateLabel,
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: viewModel.dueDate != null
                        ? '${viewModel.dueDate!.toIso8601String().split('T')[0]} '
                              '${viewModel.dueDate!.hour.toString().padLeft(2, '0')}:'
                              '${viewModel.dueDate!.minute.toString().padLeft(2, '0')}'
                        : '',
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: viewModel.dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (!context.mounted) {
                      return;
                    }
                    // ✅ Guard against disposed widget

                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                          viewModel.dueDate ?? DateTime.now(),
                        ),
                      );

                      if (!context.mounted) return; // ✅ Check again after async

                      if (time != null) {
                        final dueDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                        viewModel.setDueDate(dueDate);
                      }
                    }
                  },
                ),

                SizedBox(height: AppSizes.marginMedium),
                DropdownButtonFormField<TaskPriority>(
                  value: viewModel.priority,
                  decoration: const InputDecoration(
                    labelText: AppStrings.priorityLabel,
                    border: OutlineInputBorder(),
                  ),
                  items: TaskPriority.values
                      .map(
                        (priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority.toString().split('.').last),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => viewModel.setPriority(value!),
                ),
                SizedBox(height: AppSizes.marginMedium),
                categoriesAsync.when(
                  data: (categories) => DropdownButtonFormField<String?>(
                    value: viewModel.categoryId,
                    decoration: const InputDecoration(
                      labelText: AppStrings.categoryLabel,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text(AppStrings.noCategory),
                      ),
                      ...categories.map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      ),
                    ],
                    onChanged: (value) => viewModel.setCategoryId(value),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) =>
                      Text('${AppStrings.errorMessage}: $error'),
                ),
                SizedBox(height: AppSizes.marginMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.go('/tasks'),
                      child: const Text(AppStrings.cancelButton),
                    ),
                    SizedBox(width: AppSizes.marginSmall),
                    ElevatedButton(
                      onPressed: () async {
                        final success = await viewModel.saveTask(ref, taskId);
                        if (success) {
                          if (context.mounted) {
                            context.go('/tasks');
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to save task')),
                            );
                          }
                        }
                      },
                      child: Text(
                        taskId == null
                            ? AppStrings.addTaskButton
                            : AppStrings.updateTaskButton,
                      ),
                    ),
                    if (taskId != null) ...[
                      SizedBox(width: AppSizes.marginSmall),
                      ElevatedButton(
                        onPressed: () async {
                          await viewModel.deleteTask(ref, taskId!);
                          if (context.mounted) {
                            context.go('/tasks');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(AppStrings.deleteButton),
                      ),
                    ],
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
