import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_app/viewmodels/theme_viewmodel.dart';
import 'package:todo_app/viewmodels/todo_viewmodel.dart';
import 'package:todo_app/views/widgets/todo_input.dart';
import '../../mocks.dart';

void main() {
  late MockStorageService mockStorageService;

  setUp() {
    mockStorageService = MockStorageService();
    when(mockStorageService.saveTodos(any)).thenAnswer((_) async {});
    when(mockStorageService.loadTodos()).thenAnswer((_) async => []);
    when(mockStorageService.saveTheme(any)).thenAnswer((_) async {});
    when(mockStorageService.loadTheme()).thenAnswer((_) async => false);
  }

  testWidgets('TodoInput adds todo on submit in light and dark themes', (WidgetTester tester) async {
    for (final isDarkMode in [false, true]) {
      when(mockStorageService.loadTheme()).thenAnswer((_) async => isDarkMode);
      final container = ProviderContainer(
        overrides: [
          todoViewModelProvider.overrideWith((ref) => TodoViewModel(mockStorageService)),
          themeViewModelProvider.overrideWith((ref) => ThemeViewModel(mockStorageService)),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.light,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.dark,
              ),
            ),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const Scaffold(body: TodoInput()),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test Todo');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(container.read(todoViewModelProvider).length, 1);
      expect(container.read(todoViewModelProvider)[0].title, 'Test Todo');
      verify(mockStorageService.saveTodos(any)).called(1);

      container.dispose();
      reset(mockStorageService); // Reset mocks for next iteration
    }
  });

  testWidgets('TodoInput shows error for empty input', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        todoViewModelProvider.overrideWith((ref) => TodoViewModel(mockStorageService)),
        themeViewModelProvider.overrideWith((ref) => ThemeViewModel(mockStorageService)),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(
          home: Scaffold(body: TodoInput()),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Todo cannot be empty'), findsOneWidget);
    expect(container.read(todoViewModelProvider).length, 0);

    container.dispose();
  });
}