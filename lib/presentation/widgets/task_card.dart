import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:task_manager/core/constants/app_colors.dart';
import 'package:task_manager/core/constants/app_sizes.dart';
import 'package:task_manager/core/constants/app_strings.dart';
import 'package:task_manager/data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: AppStrings.deleteButton,
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: AppSizes.marginMedium,
          vertical: AppSizes.marginSmall,
        ),
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => onToggleComplete(),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.dueDate != null)
                Text(
                  '${AppStrings.dueDateLabel}: ${task.dueDate!.toIso8601String().split('T')[0]} ${task.dueDate!.hour.toString().padLeft(2, '0')}:${task.dueDate!.minute.toString().padLeft(2, '0')}',
                ),
              if (task.category != null)
                Chip(
                  label: Text(task.category?.name ?? AppStrings.noCategory),
                  backgroundColor: task.category?.color != null
                      ? Color(int.parse(task.category!.color.replaceFirst('#', '0xFF')))
                      : AppColors.secondary,
                ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}