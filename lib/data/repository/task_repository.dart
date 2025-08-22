import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/data/models/category_model.dart';
import 'package:uuid/uuid.dart';

class TaskRepository {
  static const String _tasksKey = 'tasks';
  static const String _categoriesKey = 'categories';

  Future<List<TaskModel>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskStrings = prefs.getStringList(_tasksKey) ?? [];
    final categories = await getCategories();
    final categoryMap = {for (var cat in categories) cat.id: cat};
    final tasks = taskStrings.map((taskJson) {
      final taskMap = jsonDecode(taskJson) as Map<String, dynamic>;
      final categoryId = taskMap['categoryId'] as String?;
      return TaskModel.fromJson(taskMap).copyWith(
        category: categoryId != null ? categoryMap[categoryId] : null,
      );
    }).toList();
    debugPrint('Retrieved ${tasks.length} tasks from SharedPreferences');
    return tasks;
  }

  Future<void> addTask(TaskModel task) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getTasks();
    final newTask = task.copyWith(id: const Uuid().v4());
    tasks.add(newTask);
    await prefs.setStringList(
      _tasksKey,
      tasks.map((t) => jsonEncode(t.toJson())).toList(),
    );
    debugPrint('Added task: ${newTask.title}');
  }

  Future<void> updateTask(TaskModel task) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await prefs.setStringList(
        _tasksKey,
        tasks.map((t) => jsonEncode(t.toJson())).toList(),
      );
      debugPrint('Updated task: ${task.title}');
    } else {
      debugPrint('Task not found for update: ${task.id}');
    }
  }

  Future<void> deleteTask(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await prefs.setStringList(
      _tasksKey,
      tasks.map((t) => jsonEncode(t.toJson())).toList(),
    );
    debugPrint('Deleted task: $taskId');
  }

  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
    debugPrint('Cleared all tasks');
  }

  Future<List<CategoryModel>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoryStrings = prefs.getStringList(_categoriesKey);
    if (categoryStrings == null || categoryStrings.isEmpty) {
      final defaultCategories = [
        CategoryModel(id: const Uuid().v4(), name: 'Work', color: '#FF0000', description: 'Job-related tasks'),
        CategoryModel(id: const Uuid().v4(), name: 'Personal', color: '#00FF00', description: 'Errands, family, self-care'),
        CategoryModel(id: const Uuid().v4(), name: 'School/Study', color: '#0000FF', description: 'Assignments, exams, projects'),
        CategoryModel(id: const Uuid().v4(), name: 'Home', color: '#FFA500', description: 'Cleaning, maintenance, bills'),
        CategoryModel(id: const Uuid().v4(), name: 'Shopping', color: '#800080', description: 'Groceries, items to buy'),
        CategoryModel(id: const Uuid().v4(), name: 'Errands', color: '#00FFFF', description: 'Tasks outside the home'),
        CategoryModel(id: const Uuid().v4(), name: 'Church', color: '#FFC0CB', description: 'Church-related activities'),
      ];
      await prefs.setStringList(
        _categoriesKey,
        defaultCategories.map((c) => jsonEncode(c.toJson())).toList(),
      );
      debugPrint('Initialized default categories: ${defaultCategories.length}');
      return defaultCategories;
    }
    final categories = categoryStrings.map((catJson) => CategoryModel.fromJson(jsonDecode(catJson))).toList();
    debugPrint('Retrieved ${categories.length} categories from SharedPreferences');
    return categories;
  }
}