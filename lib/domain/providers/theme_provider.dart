import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateProvider<bool>((ref) {
  // Default to light theme
  return false;
});

// Provider to initialize theme from SharedPreferences
final themeInitializerProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isDarkTheme') ?? false;
});

// Provider to toggle and save theme
final themeToggleProvider = Provider((ref) => (bool isDark) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isDarkTheme', isDark);
  ref.read(themeProvider.notifier).state = isDark;
});