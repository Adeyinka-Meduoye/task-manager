import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/data/models/category_model.dart';
import 'package:task_manager/data/repository/task_repository.dart';

// Provider for the task repository
final taskRepositoryProvider = Provider<TaskRepository>((ref) => TaskRepository());

// Provider for the list of all categories
final categoryListProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return await repository.getCategories();
});

// Provider for a single category by ID
final categoryProvider = Provider.family<CategoryModel?, String>((ref, id) {
  final categories = ref.watch(categoryListProvider).valueOrNull ?? [];
  final category = categories.firstWhere(
    (cat) => cat.id == id,
    orElse: () => CategoryModel(id: '', name: '', color: '#000000'),
  );
  return category.id.isEmpty ? null : category;
});