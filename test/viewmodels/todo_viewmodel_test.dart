import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/services/notification_service.dart';
import 'package:todo_app/services/storage_service.dart';
import 'package:todo_app/viewmodels/todo_viewmodel.dart';
import '../mocks.dart';

@GenerateMocks([StorageService, NotificationService])
void main() {
  late MockStorageService mockStorageService;
  late MockNotificationService mockNotificationService;
  late ProviderContainer container;
  late TodoViewModel todoViewModel;

  setUp() {
    mockStorageService = MockStorageService();
    mockNotificationService = MockNotificationService();
    container = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWithValue(mockStorageService),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        todoViewModelProvider.overrideWith(
          (ref) => TodoViewModel(mockStorageService, mockNotificationService),
        ),
      ],
    );
    todoViewModel = container.read(todoViewModelProvider.notifier);
    when(mockStorageService.saveTodos(any)).thenAnswer((_) async {});
    when(mockStorageService.saveSortPreference(any)).thenAnswer((_) async {});
    when(mockStorageService.saveCustomCategories(any)).thenAnswer((_) async {});
    when(mockNotificationService.zonedSchedule(any, any, any, any, any, androidScheduleMode: anyNamed('androidAllowWhileIdle'))).thenAnswer((_) async {});
    when(mockNotificationService.cancelNotification(any)).thenAnswer((_) async {});
  })

  tearDown() {
    container.dispose();
  })

  test('Add todo with due date and category schedules notification', () async {
    final dueDate = DateTime.now().add(const Duration(days: 1));
    todoViewModel.addTodo('Test Todo', dueDate: dueDate, category: 'Work');
    expect(todoViewModel.state.length, 1);
    expect(todoViewModel.state[0].title, 'Test Todo');
    expect(todoViewModel.state[0].dueDate, dueDate);
    expect(todoViewModel.state[0].category, 'Work');
    verify(mockStorageService.saveTodos(any)).called(1);
    verify(mockNotificationService.zonedSchedule(
      any,
      'Todo Due Soon: Test Todo',
      any,
      any,
      any,
      androidAllowWhileIdle: true,
    )).called(1);
  });

  test('Toggle todo updates completion status', () async {
    todoViewModel.addTodo('Test Todo');
    final todoId = todoViewModel.state[0].id;
    todoViewModel.toggleTodo(todoId);
    expect(todoViewModel.state[0].isCompleted, true);
    verify(mockStorageService.saveTodos(any)).called(2);
  });

  test('Delete todo cancels notification', () async {
    final dueDate = DateTime.now().add(const Duration(days: 1));
    todoViewModel.addTodo('Test Todo', dueDate: dueDate);
    final todoId = todoViewModel.state[0].id;
    todoViewModel.deleteTodo(todoId);
    expect(todoViewModel.state.length, 0);
    verify(mockStorageService.saveTodos(any)).called(2);
    verify(mockNotificationService.cancelNotification(todoId.hashCode)).called(1);
  });

  test('Edit todo updates title, due date, and category with notification', () async {
    todoViewModel.addTodo('Test Todo');
    final todoId = todoViewModel.state[0].id;
    final newDueDate = DateTime.now().add(const Duration(days: 2));
    todoViewModel.editTodo(todoId, 'Updated Todo', dueDate: newDueDate, category: 'Personal');
    expect(todoViewModel.state[0].title, 'Updated Todo');
    expect(todoViewModel.state[0].dueDate, newDueDate);
    expect(todoViewModel.state[0].category, 'Personal');
    verify(mockStorageService.saveTodos(any)).called(2);
    verify(mockNotificationService.zonedSchedule(
      any,
      'Todo Due Soon: Updated Todo',
      any,
      any,
      any,
      androidAllowWhileIdle: true,
    )).called(1);
  });

  test('Clear completed cancels notifications', () async {
    final dueDate = DateTime.now().add(const Duration(days: 1));
    todoViewModel.addTodo('Test Todo', dueDate: dueDate);
    final todoId = todoViewModel.state[0].id;
    todoViewModel.toggleTodo(todoId);
    todoViewModel.clearCompleted();
    expect(todoViewModel.state.length, 0);
    verify(mockStorageService.saveTodos(any)).called(3);
    verify(mockNotificationService.cancelNotification(todoId.hashCode)).called(1);
  });

  test('Filter todos by completion status', () async {
    todoViewModel.addTodo('Todo 1');
    todoViewModel.addTodo('Todo 2');
    final todoId = todoViewModel.state[0].id;
    todoViewModel.toggleTodo(todoId);

    todoViewModel.setFilter(TodoFilter.completed);
    expect(todoViewModel.filteredTodos.length, 1);
    expect(todoViewModel.filteredTodos[0].isCompleted, true);

    todoViewModel.setFilter(TodoFilter.active);
    expect(todoViewModel.filteredTodos.length, 1);
    expect(todoViewModel.filteredTodos[0].isCompleted, false);

    todoViewModel.setFilter(TodoFilter.all);
    expect(todoViewModel.filteredTodos.length, 2);
  });

  test('Filter todos by custom category', () async {
    when(mockStorageService.loadCustomCategories()).thenAnswer((_) async => ['Work', 'Personal', 'Custom1']);
    await todoViewModel.loadCustomCategories();
    todoViewModel.addTodo('Todo 1', category: 'Custom1');
    todoViewModel.addTodo('Todo 2', category: 'Work');

    todoViewModel.setCategoryFilter(CategoryFilter.custom);
    expect(todoViewModel.filteredTodos.length, 1);
    expect(todoViewModel.filteredTodos[0].category, 'Custom1');

    todoViewModel.setCategoryFilter(CategoryFilter.work);
    expect(todoViewModel.filteredTodos.length, 1);
    expect(todoViewModel.filteredTodos[0].category, 'Work');

    todoViewModel.setCategoryFilter(CategoryFilter.all);
    expect(todoViewModel.filteredTodos.length, 2);
  });

  test('Sort todos by due date', () async {
    final dueDate1 = DateTime.now().add(const Duration(days: 2));
    final dueDate2 = DateTime.now().add(const Duration(days: 1));
    todoViewModel.addTodo('Todo 1', dueDate: dueDate1);
    todoViewModel.addTodo('Todo 2', dueDate: dueDate2);
    todoViewModel.setSortType(SortType.dueDate);
    expect(todoViewModel.state[0].title, 'Todo 2');
    expect(todoViewModel.state[1].title, 'Todo 1');
    verify(mockStorageService.saveSortPreference('due_date')).called(1);
  });

  test('Add custom category', () async {
    when(mockStorageService.loadCustomCategories()).thenAnswer((_) async => ['Work', 'Personal', 'Other']);
    await todoViewModel.loadCustomCategories();
    todoViewModel.addCustomCategory('Custom1');
    expect(todoViewModel.customCategories, ['Work', 'Personal', 'Other', 'Custom1']);
    verify(mockStorageService.saveCustomCategories(any)).called(1);
  });
}