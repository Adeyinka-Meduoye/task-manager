import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../viewmodels/todo_viewmodel.dart';
import '../widgets/todo_input.dart';
import '../widgets/todo_item.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _filterAnimationController;
  late Animation<Offset> _filterAnimation;

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _filterAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTodos = ref.watch(
      todoViewModelProvider.notifier.select((vm) => vm.filteredTodos),
    );
    final filter = ref.watch(
      todoViewModelProvider.notifier.select((vm) => vm.filter),
    );
    final sortType = ref.watch(
      todoViewModelProvider.notifier.select((vm) => vm.sortType),
    );
    final categoryFilter = ref.watch(
      todoViewModelProvider.notifier.select((vm) => vm.categoryFilter),
    );
    final totalCount = ref.watch(
      todoViewModelProvider.notifier.select((vm) => vm.totalCount),
    );
    final completedCount = ref.watch(
      todoViewModelProvider.notifier.select((vm) => vm.completedCount),
    );
    final pendingCount = ref.watch(
      todoViewModelProvider.notifier.select((vm) => vm.pendingCount),
    );
    final isDarkMode = ref.watch(themeViewModelProvider);

    ref.listen(todoViewModelProvider.notifier.select((vm) => vm.filter), (previous, next) {
      if (previous != next) {
        _filterAnimationController.forward(from: 0);
      }
    });
    ref.listen(todoViewModelProvider.notifier.select((vm) => vm.categoryFilter), (previous, next) {
      if (previous != next) {
        _filterAnimationController.forward(from: 0);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          Semantics(
            label: 'Toggle theme',
            hint: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
            child: IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => ref.read(themeViewModelProvider.notifier).toggleTheme(),
              tooltip: 'Toggle Theme',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const TodoInput(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: 'Todo statistics',
                  child: Text(
                    'Total: $totalCount | Done: $completedCount | Pending: $pendingCount | State: ${ref.watch(todoViewModelProvider).length} | Filtered: ${filteredTodos.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Semantics(
                        label: 'Filter todos',
                        hint: 'Select filter for todo list',
                        child: DropdownButton<TodoFilter>(
                          value: filter,
                          onChanged: (newFilter) {
                            if (newFilter != null) {
                              ref.read(todoViewModelProvider.notifier).setFilter(newFilter);
                            }
                          },
                          items: TodoFilter.values
                              .map((filter) => DropdownMenuItem(
                                    value: filter,
                                    child: Row(
                                      children: [
                                        Icon(
                                          filter == TodoFilter.all
                                              ? Icons.list
                                              : filter == TodoFilter.active
                                                  ? Icons.check_box_outline_blank
                                                  : Icons.check_box,
                                          size: 20,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(filter.toString().split('.').last),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          borderRadius: BorderRadius.circular(8),
                          icon: const Icon(Icons.filter_list),
                          underline: Container(
                            height: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Semantics(
                        label: 'Filter by category',
                        hint: 'Select category filter for todo list',
                        child: DropdownButton<CategoryFilter>(
                          value: categoryFilter,
                          onChanged: (newCategoryFilter) {
                            if (newCategoryFilter != null) {
                              ref.read(todoViewModelProvider.notifier).setCategoryFilter(newCategoryFilter);
                            }
                          },
                          items: CategoryFilter.values
                              .map((catFilter) => DropdownMenuItem(
                                    value: catFilter,
                                    child: Row(
                                      children: [
                                        Icon(
                                          catFilter == CategoryFilter.all
                                              ? Icons.category
                                              : catFilter == CategoryFilter.work
                                                  ? Icons.work
                                                  : catFilter == CategoryFilter.personal
                                                      ? Icons.person
                                                      : catFilter == CategoryFilter.other
                                                          ? Icons.miscellaneous_services
                                                          : Icons.star,
                                          size: 20,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(catFilter.toString().split('.').last),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          borderRadius: BorderRadius.circular(8),
                          icon: const Icon(Icons.category),
                          underline: Container(
                            height: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Semantics(
                        label: 'Sort todos',
                        hint: 'Select sorting option for todo list',
                        child: DropdownButton<SortType>(
                          value: sortType,
                          onChanged: (newSortType) {
                            if (newSortType != null) {
                              ref.read(todoViewModelProvider.notifier).setSortType(newSortType);
                            }
                          },
                          items: SortType.values
                              .map((sort) => DropdownMenuItem(
                                    value: sort,
                                    child: Row(
                                      children: [
                                        Icon(
                                          sort == SortType.dateAsc
                                              ? Icons.arrow_upward
                                              : sort == SortType.dateDesc
                                                  ? Icons.arrow_downward
                                                  : sort == SortType.alpha
                                                      ? Icons.sort_by_alpha
                                                      : Icons.calendar_today,
                                          size: 20,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          sort == SortType.dateAsc
                                              ? 'Date (Oldest)'
                                              : sort == SortType.dateDesc
                                                  ? 'Date (Newest)'
                                                  : sort == SortType.alpha
                                                      ? 'Alphabetical'
                                                      : 'Due Date',
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          borderRadius: BorderRadius.circular(8),
                          icon: const Icon(Icons.sort),
                          underline: Container(
                            height: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Semantics(
              label: 'Clear completed todos',
              hint: 'Remove all completed todos',
              child: ElevatedButton(
                onPressed: () => ref.read(todoViewModelProvider.notifier).clearCompleted(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear Completed'),
              ),
            ),
          ),
          Expanded(
            child: Semantics(
              label: 'Todo list',
              child: SlideTransition(
                position: _filterAnimation,
                child: AnimatedList(
                  key: ref.read(todoViewModelProvider.notifier).animatedListKey,
                  initialItemCount: filteredTodos.length,
                  itemBuilder: (context, index, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          elevation: 2,
                          child: TodoItem(todo: filteredTodos[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}