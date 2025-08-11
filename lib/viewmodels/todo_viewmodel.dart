import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/main.dart';
import '../models/todo.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

enum TodoFilter { all, active, completed }
enum SortType { dateAsc, dateDesc, alpha, dueDate }
enum CategoryFilter { all, work, personal, other, custom }

class TodoViewModel extends StateNotifier<List<Todo>> {
  final StorageService _storageService;
  final NotificationService _notificationService;
  TodoFilter _filter = TodoFilter.all;
  SortType _sortType = SortType.dateAsc;
  CategoryFilter _categoryFilter = CategoryFilter.all;
  List<String> _customCategories = ['Work', 'Personal', 'Other'];
  final GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();

  TodoViewModel(this._storageService, this._notificationService) : super([]) {
    loadTodos();
    loadSortPreference();
    loadCustomCategories();
  }

  TodoFilter get filter => _filter;
  SortType get sortType => _sortType;
  CategoryFilter get categoryFilter => _categoryFilter;
  List<String> get customCategories => _customCategories;

  Future<void> loadTodos() async {
    state = await _storageService.loadTodos();
    _applySort();
  }

  Future<void> loadSortPreference() async {
    final sortPref = await _storageService.loadSortPreference();
    _sortType = SortType.values.firstWhere(
      (type) => type.toString().split('.').last == sortPref,
      orElse: () => SortType.dateAsc,
    );
    _applySort();
  }

  Future<void> loadCustomCategories() async {
    _customCategories = await _storageService.loadCustomCategories();
  }

  void addCustomCategory(String category) {
    if (category.isNotEmpty && !_customCategories.contains(category)) {
      _customCategories = [..._customCategories, category];
      _storageService.saveCustomCategories(_customCategories);
      state = [...state]; // Trigger UI update
    }
  }

  void addTodo(String title, {DateTime? dueDate, String? category}) {
    if (title.isNotEmpty) {
      final newTodo = Todo(title: title, dueDate: dueDate, category: category);
      state = [...state, newTodo];
      _applySort();
      _storageService.saveTodos(state);
      final index = state.indexWhere((todo) => todo.id == newTodo.id);
      animatedListKey.currentState?.insertItem(index);
      if (dueDate != null) {
        _scheduleNotification(newTodo);
      }
    }
  }

  void toggleTodo(String id) {
    state = state.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(isCompleted: !todo.isCompleted);
      }
      return todo;
    }).toList();
    _applySort();
    _storageService.saveTodos(state);
  }

  void deleteTodo(String id) {
    final index = state.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      final removedTodo = state[index];
      state = state.where((todo) => todo.id != id).toList();
      _storageService.saveTodos(state);
      animatedListKey.currentState?.removeItem(
        index,
        (context, animation) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(title: Text(removedTodo.title)),
            ),
          ),
        ),
        duration: const Duration(milliseconds: 300),
      );
      _notificationService.cancelNotification(removedTodo.id.hashCode);
    }
  }

  void editTodo(String id, String newTitle, {DateTime? dueDate, String? category}) {
    if (newTitle.isNotEmpty) {
      state = state.map((todo) {
        if (todo.id == id) {
          final updatedTodo = todo.copyWith(
            title: newTitle,
            dueDate: dueDate,
            category: category,
          );
          if (dueDate != null) {
            _scheduleNotification(updatedTodo);
          } else {
            _notificationService.cancelNotification(todo.id.hashCode);
          }
          return updatedTodo;
        }
        return todo;
      }).toList();
      _applySort();
      _storageService.saveTodos(state);
    }
  }

  void clearCompleted() {
    final completedIndices = state
        .asMap()
        .entries
        .where((entry) => entry.value.isCompleted)
        .map((entry) => entry.key)
        .toList()
        .reversed;
    for (final index in completedIndices) {
      final todo = state[index];
      _notificationService.cancelNotification(todo.id.hashCode);
    }
    state = state.where((todo) => !todo.isCompleted).toList();
    _storageService.saveTodos(state);
    for (final index in completedIndices) {
      animatedListKey.currentState?.removeItem(
        index,
        (context, animation) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: const Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(),
            ),
          ),
        ),
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void setFilter(TodoFilter filter) {
    _filter = filter;
    state = [...state];
  }

  void setCategoryFilter(CategoryFilter categoryFilter) {
    _categoryFilter = categoryFilter;
    state = [...state];
  }

  void setSortType(SortType sortType) {
    _sortType = sortType;
    _applySort();
    _storageService.saveSortPreference(sortType.toString().split('.').last);
  }

  void _applySort() {
    final sortedList = List<Todo>.from(state);
    switch (_sortType) {
      case SortType.dateAsc:
        sortedList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortType.dateDesc:
        sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortType.alpha:
        sortedList.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortType.dueDate:
        sortedList.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
    }
    state = sortedList;
  }

  void _scheduleNotification(Todo todo) {
    if (todo.dueDate != null) {
      final notificationTime = todo.dueDate!.subtract(const Duration(hours: 1));
      if (notificationTime.isAfter(DateTime.now())) {
        _notificationService.scheduleNotification(
          id: todo.id.hashCode,
          title: 'Todo Due Soon: ${todo.title}',
          body: 'Due on ${todo.dueDate!.toLocal().toString().split(' ')[0]}',
          scheduledTime: notificationTime,
        );
      }
    }
  }

  int get totalCount => state.length;
  int get completedCount => state.where((todo) => todo.isCompleted).length;
  int get pendingCount => state.where((todo) => !todo.isCompleted).length;

  List<Todo> get filteredTodos {
    List<Todo> filtered;
    switch (_filter) {
      case TodoFilter.all:
        filtered = state;
        break;
      case TodoFilter.active:
        filtered = state.where((todo) => !todo.isCompleted).toList();
        break;
      case TodoFilter.completed:
        filtered = state.where((todo) => todo.isCompleted).toList();
        break;
    }
    switch (_categoryFilter) {
      case CategoryFilter.all:
        return filtered;
      case CategoryFilter.work:
        return filtered.where((todo) => todo.category == 'Work').toList();
      case CategoryFilter.personal:
        return filtered.where((todo) => todo.category == 'Personal').toList();
      case CategoryFilter.other:
        return filtered.where((todo) => todo.category == 'Other').toList();
      case CategoryFilter.custom:
        return filtered
            .where((todo) => todo.category != null && !_customCategories.contains(todo.category))
            .toList();
    }
  }

  List<String> get availableCategories => _customCategories;
}

final todoViewModelProvider =
    StateNotifierProvider<TodoViewModel, List<Todo>>((ref) {
  return TodoViewModel(
    ref.read<StorageService>(storageServiceProvider),
    ref.read(notificationServiceProvider),
  );
});