import 'package:flutter/material.dart';
import 'package:task_manager/data/models/task_model.dart';

class PriorityIndicator extends StatelessWidget {
  final TaskPriority priority;

  const PriorityIndicator({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          priority == TaskPriority.high
              ? Icons.priority_high
              : priority == TaskPriority.medium
                  ? Icons.low_priority
                  : Icons.arrow_downward,
          color: priority == TaskPriority.high
              ? Colors.red
              : priority == TaskPriority.medium
                  ? Colors.orange
                  : Colors.green,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          priority.toString().split('.').last,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}