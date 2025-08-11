import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_app/services/storage_service.dart';
import 'package:todo_app/viewmodels/theme_viewmodel.dart';
import '../mocks.dart';

@GenerateMocks([StorageService])
void main() {
  late MockStorageService mockStorageService;
  late ProviderContainer container;
  late ThemeViewModel themeViewModel;

  setUp(() {
    mockStorageService = MockStorageService();
    container = ProviderContainer(
      overrides: [
        themeViewModelProvider.overrideWith(
          (ref) => ThemeViewModel(mockStorageService),
        ),
      ],
    );
    themeViewModel = container.read(themeViewModelProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  test('Initial theme is light (false)', () {
    expect(themeViewModel.state, false);
  });

  test('Load theme from storage', () async {
    when(mockStorageService.loadTheme()).thenAnswer((_) async => true);
    await themeViewModel.loadTheme();
    expect(themeViewModel.state, true);
    verify(mockStorageService.loadTheme()).called(1);
  });

  test('Toggle theme changes state and saves to storage', () async {
    when(mockStorageService.saveTheme(true)).thenAnswer((_) async {});
    themeViewModel.toggleTheme();
    expect(themeViewModel.state, true);
    verify(mockStorageService.saveTheme(true)).called(1);

    themeViewModel.toggleTheme();
    expect(themeViewModel.state, false);
    verify(mockStorageService.saveTheme(false)).called(1);
  });
}