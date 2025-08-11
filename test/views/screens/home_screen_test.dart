import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_app/services/notification_service.dart';
import 'package:todo_app/services/storage_service.dart';
import 'package:todo_app/viewmodels/theme_viewmodel.dart';
import 'package:todo_app/viewmodels/todo_viewmodel.dart';
import 'package:todo_app/views/screens/home_screen.dart';
import '../../mocks.dart';

void main() {
  late MockStorageService mockStorageService;
  late MockNotificationService mockNotificationService;

  setUp() {
    mockStorageService = MockStorageService();
    mockNotificationService = MockNotificationService();
    when(mockStorageService.saveTodos(any)).thenAnswer((_) async {});
    when(mockStorageService.loadTodos()).thenAnswer((_) async => []);
    when(mockStorageService.saveTheme(any)).thenAnswer((_) async {});
    when(mockStorageService.loadTheme()).thenAnswer((_) async => false);
    when(mockStorageService.saveSortPreference(any)).thenAnswer((_) async {});
    when(mockStorageService.loadSortPreference()).thenAnswer((_) async => 'date_asc');
    when(mockStorageService.loadCustomCategories()).thenAnswer((_) async => ['Work', 'Personal', 'Other']);
    when(mockStorageService.saveCustomCategories(any)).thenAnswer((_) async {});
    when(mockNotificationService.scheduleNotification(any, any, any, any)).thenAnswer((_) async {});
    when(mockNotificationService.cancelNotification(any)).thenAnswer((_) async {});
  }

  testWidgets('Toggles theme when button is pressed', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWithValue(mockStorageService),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        todoViewModelProvider.overrideWith((ref) => TodoViewModel(mockStorageService, mockNotificationService)),
        themeViewModelProvider.overrideWith((ref) => ThemeViewModel(mockStorageService)),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    expect(container.read(themeViewModelProvider), false);
    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();
    expect(container.read(themeViewModelProvider), true);
    verify(mockStorageService.saveTheme(true)).called(1);

    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();
    expect(container.read(themeViewModelProvider), false);
    verify(mockStorageService.saveTheme(false)).called(1);

    container.dispose();
  });

  testWidgets('Renders todo list and filter correctly with semantics', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWithValue(mockStorageService),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        todoViewModelProvider.overrideWith((ref) => TodoViewModel(mockStorageService, mockNotificationService)),
        themeViewModelProvider.overrideWith((ref) => ThemeViewModel(mockStorageService)),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          home: const HomeScreen(),
          theme: ThemeData.light(useMaterial3: true),
        ),
      ),
    );

    expect(find.text('Todo App'), findsOneWidget);
    expect(find.byType(DropdownButton<TodoFilter>), findsOneWidget);
    expect(find.byType(DropdownButton<CategoryFilter>), findsOneWidget);
    expect(find.byType(DropdownButton<SortType>), findsOneWidget);
    expect(find.text('Total: 0 | Done: 0 | Pending: 0'), findsOneWidget);
    expect(find.text('Clear Completed'), findsOneWidget);
    expect(find.bySemanticsLabel('Toggle theme'), findsOneWidget);
    expect(find.bySemanticsLabel('Filter todos'), findsOneWidget);
    expect(find.bySemanticsLabel('Filter by category'), findsOneWidget);
    expect(find.bySemanticsLabel('Sort todos'), findsOneWidget);
    expect(find.bySemanticsLabel('Clear completed todos'), findsOneWidget);

    container.dispose();
  });

  testWidgets('Adds todo with due date and custom category', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWithValue(mockStorageService),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        todoViewModelProvider.overrideWith((ref) => TodoViewModel(mockStorageService, mockNotificationService)),
        themeViewModelProvider.overrideWith((ref) => ThemeViewModel(mockStorageService)),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          home: const HomeScreen(),
          theme: ThemeData.light(useMaterial3: true),
        ),
      ),
    );

    await tester.enterText(find.bySemanticsLabel('New todo input'), 'Test Todo');
    await tester.tap(find.text('Set Due Date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.enterText(find.bySemanticsLabel('New category input'), 'Custom1');
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom1').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.text('Test Todo'), findsOneWidget);
    expect(find.text('Category: Custom1'), findsOneWidget);
    expect(find.byType(SlideTransition), findsWidgets);
    expect(find.bySemanticsLabel('Todo item: Test Todo'), findsOneWidget);
    verify(mockNotificationService.scheduleNotification(any, any, any, any)).called(1);

    container.dispose();
  });

  testWidgets('Filters by custom category and sorts by due date', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWithValue(mockStorageService),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        todoViewModelProvider.overrideWith((ref) => TodoViewModel(mockStorageService, mockNotificationService)),
        themeViewModelProvider.overrideWith((ref) => ThemeViewModel(mockStorageService)),
      ],
    );

    final dueDate1 = DateTime.now().add(const Duration(days: 2));
    final dueDate2 = DateTime.now().add(const Duration(days: 1));
    container.read(todoViewModelProvider.notifier).addCustomCategory('Custom1');
    container.read(todoViewModelProvider.notifier).addTodo('Todo 1', category: 'Custom1', dueDate: dueDate1);
    container.read(todoViewModelProvider.notifier).addTodo('Todo 2', category: 'Work', dueDate: dueDate2);
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

    await tester.tap(find.byType(DropdownButton<CategoryFilter>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('custom').last);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.text('Todo 1'), findsOneWidget);
    expect(find.text('Todo 2'), findsNothing);

    await tester.tap(find.byType(DropdownButton<SortType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Due Date').last);
    await tester.pumpAndSettle();

    container.read(todoViewModelProvider.notifier).setCategoryFilter(CategoryFilter.all);
    await tester.pumpAndSettle();

    expect(find.text('Todo 2'), findsOneWidget);
    expect(find.text('Todo 1'), findsOneWidget);

    container.dispose();
  });
}