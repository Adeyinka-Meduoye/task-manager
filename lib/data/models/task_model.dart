import 'package:task_manager/data/models/category_model.dart';

enum TaskPriority { low, medium, high }

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final bool isCompleted;
  final CategoryModel? category;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = TaskPriority.low,
    this.isCompleted = false,
    this.category,
  });

  // Convert TaskModel to JSON for SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.toString(),
      'isCompleted': isCompleted,
      'category': category?.toJson(),
    };
  }

  // Create TaskModel from JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => TaskPriority.low,
      ),
      isCompleted: json['isCompleted'] as bool,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  // CopyWith method for updating TaskModel
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    CategoryModel? category,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
    );
  }
}