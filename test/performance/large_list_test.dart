import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_app/viewmodels/theme_viewmodel.dart';
import 'package:todo_app/viewmodels/todo_viewmodel.dart';
import 'package:todo_app/views/screens/home_screen.dart';
import '../mocks.dart';

void main() {
  late MockStorageService mockStorageService;

  setUp(() {
    mockStorageService = MockStorageService();
    when(mockStorageService.saveTodos(any)).thenAnswer((_) async {});
    when(mockStorageService.loadTodos()).thenAnswer((_) async => []);
    when(mockStorageService.saveTheme(any)).thenAnswer((_) async {});
    when(mockStorageService.loadTheme()).thenAnswer((_) async => false);
    when(mockStorageService.saveSortPreference(any)).thenAnswer((_) async {});
    when(mockStorageService.loadSortPreference()).thenAnswer((_) async => 'date_asc');
  });

  testWidgets('Handles large todo list efficiently', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        todoViewModelProvider.overrideWith((ref) => TodoViewModel(mockStorageService)),
        themeViewModelProvider.overrideWith((ref) => ThemeViewModel(mockStorageService)),
      ],
    );

    // Simulate large todo list
    final todoViewModel = container.read(todoViewModelProvider.notifier);
    for (int i = 0; i < 1000; i++) {
      todoViewModel.addTodo('Todo $i');
    }
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          home: const HomeScreen(),
          theme: ThemeData.light(useMaterial3: true),
        ),
      ),
    );

    // Verify rendering
    expect(find.text('Todo 0'), findsOneWidget);
    expect(find.text('Total: 1000 | Done: 0 | Pending: 1000'), findsOneWidget);

    // Scroll to bottom
    await tester.drag(find.byType(AnimatedList), const Offset(0, -10000));
    await tester.pumpAndSettle();
    expect(find.text('Todo 999'), findsOneWidget);

    // Change filter
    await tester.tap(find.byType(DropdownButton<TodoFilter>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('active').last);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.byType(SlideTransition), findsWidgets);

    container.dispose();
  });
}