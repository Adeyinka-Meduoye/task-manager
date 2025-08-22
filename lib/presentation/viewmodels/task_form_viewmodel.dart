import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/domain/providers/task_provider.dart';
import 'package:task_manager/domain/providers/category_provider.dart' hide taskRepositoryProvider;

class TaskFormViewModel {
  final formKey = GlobalKey<FormState>();
  String _title = '';
  String? _description;
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.low;
  String? _categoryId;

  String get title => _title;
  String? get description => _description;
  DateTime? get dueDate => _dueDate;
  TaskPriority get priority => _priority;
  String? get categoryId => _categoryId;

  void setTitle(String value) {
    _title = value;
    debugPrint('Set title: $value');
  }

  void setDescription(String? value) {
    _description = value;
    debugPrint('Set description: $value');
  }

  void setDueDate(DateTime? value) {
    _dueDate = value;
    debugPrint('Set dueDate: $value');
  }

  void setPriority(TaskPriority value) {
    _priority = value;
    debugPrint('Set priority: $value');
  }

  void setCategoryId(String? value) {
    _categoryId = value;
    debugPrint('Set categoryId: $value');
  }

  TaskFormViewModel({TaskModel? task}) {
    if (task != null) {
      _title = task.title;
      _description = task.description;
      _dueDate = task.dueDate;
      _priority = task.priority;
      _categoryId = task.category?.id;
      debugPrint('Initialized TaskFormViewModel with task: ${task.title}');
    }
  }

  Future<bool> saveTask(WidgetRef ref, String? taskId) async {
    debugPrint('Attempting to save task. TaskId: $taskId, Title: $_title, CategoryId: $_categoryId');
    if (formKey.currentState?.validate() ?? false) {
      try {
        final repository = ref.read(taskRepositoryProvider);
        final category = _categoryId != null ? ref.read(categoryProvider(_categoryId!)) : null;
        debugPrint('Category for task: ${category?.name}');

        final task = TaskModel(
          id: taskId ?? '',
          title: _title,
          description: _description,
          dueDate: _dueDate,
          priority: _priority,
          category: category,
        );

        if (taskId == null) {
          await repository.addTask(task);
          debugPrint('Task added successfully: $_title');
        } else {
          await repository.updateTask(task);
          debugPrint('Task updated successfully: $_title');
        }
        ref.invalidate(taskListProvider);
        return true;
      } catch (e) {
        debugPrint('Error saving task: $e');
        return false;
      }
    } else {
      debugPrint('Form validation failed');
      return false;
    }
  }

  Future<void> deleteTask(WidgetRef ref, String taskId) async {
    final repository = ref.read(taskRepositoryProvider);
    await repository.deleteTask(taskId);
    ref.invalidate(taskListProvider);
    debugPrint('Task deleted: $taskId');
  }
}

final taskFormViewModelProvider = Provider.family<TaskFormViewModel, String?>((ref, taskId) {
  final task = taskId != null ? ref.watch(taskProvider(taskId)) : null;
  return TaskFormViewModel(task: task);
});