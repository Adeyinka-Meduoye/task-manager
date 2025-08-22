import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/data/models/category_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

Future<void> initializeAppData() async {
  final prefs = await SharedPreferences.getInstance();
  // Initialize theme if not set
  if (!prefs.containsKey('themeMode')) {
    await prefs.setString('themeMode', ThemeMode.light.toString());
    debugPrint('Initialized themeMode to ThemeMode.light');
  }
  // Initialize categories and tasks
  final categories = [
    CategoryModel(id: Uuid().v4(), name: 'Work', color: '#FF0000', description: 'Job-related tasks'),
    CategoryModel(id: Uuid().v4(), name: 'Personal', color: '#00FF00', description: 'Errands, family, self-care'),
    CategoryModel(id: Uuid().v4(), name: 'School/Study', color: '#0000FF', description: 'Assignments, exams, projects'),
    CategoryModel(id: Uuid().v4(), name: 'Home', color: '#FFA500', description: 'Cleaning, maintenance, bills'),
    CategoryModel(id: Uuid().v4(), name: 'Shopping', color: '#800080', description: 'Groceries, items to buy'),
    CategoryModel(id: Uuid().v4(), name: 'Errands', color: '#00FFFF', description: 'Tasks outside the home'),
    CategoryModel(id: Uuid().v4(), name: 'Church', color: '#FFC0CB', description: 'Church-related activities'),
  ];
  final tasks = [
    TaskModel(
      id: '1',
      title: 'Test Task',
      description: 'This is a test task',
      dueDate: DateTime.now().add(Duration(days: 1, hours: 2)),
      priority: TaskPriority.medium,
      isCompleted: false,
      category: categories[0],
    ),
    TaskModel(
      id: '2',
      title: 'Another Task',
      priority: TaskPriority.high,
      isCompleted: true,
    ),
  ];
  await prefs.setStringList('categories', categories.map((c) => jsonEncode(c.toJson())).toList());
  await prefs.setStringList('tasks', tasks.map((t) => jsonEncode(t.toJson())).toList());
  debugPrint('Initialized test data: ${categories.length} categories, ${tasks.length} tasks');
}