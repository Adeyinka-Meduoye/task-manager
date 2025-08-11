import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class StorageService {
  static const String _todosKey = 'todos';
  static const String _themeKey = 'theme';
  static const String _sortKey = 'sort';
  static const String _categoriesKey = 'categories';

  Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getStringList(_todosKey) ?? [];
    return todosJson
        .map((json) => Todo.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = todos.map((todo) => jsonEncode(todo.toJson())).toList();
    await prefs.setStringList(_todosKey, todosJson);
  }

  Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  Future<void> saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  Future<String> loadSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sortKey) ?? 'date_asc';
  }

  Future<void> saveSortPreference(String sortType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortKey, sortType);
  }

  Future<List<String>> loadCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_categoriesKey) ?? ['Work', 'Personal', 'Other'];
  }

  Future<void> saveCustomCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_categoriesKey, categories);
  }
}