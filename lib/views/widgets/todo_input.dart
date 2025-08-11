import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/todo_viewmodel.dart';

class TodoInput extends ConsumerStatefulWidget {
  const TodoInput({super.key});

  @override
  ConsumerState<TodoInput> createState() => _TodoInputState();
}

class _TodoInputState extends ConsumerState<TodoInput> {
  final _controller = TextEditingController();
  final _categoryController = TextEditingController();
  DateTime? _dueDate;
  String? _category;

  @override
  void dispose() {
    _controller.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _addTodo() {
    if (_controller.text.trim().isNotEmpty) {
      ref.read(todoViewModelProvider.notifier).addTodo(
            _controller.text.trim(),
            dueDate: _dueDate,
            category: _category,
          );
      _controller.clear();
      setState(() {
        _dueDate = null;
        _category = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todo cannot be empty')),
      );
    }
  }

  void _addCustomCategory() {
    final newCategory = _categoryController.text.trim();
    if (newCategory.isNotEmpty) {
      ref.read(todoViewModelProvider.notifier).addCustomCategory(newCategory);
      setState(() {
        _category = newCategory;
        _categoryController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(todoViewModelProvider.notifier.select((vm) => vm.availableCategories));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  label: 'New todo input',
                  hint: 'Enter a new todo item',
                  textField: true,
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter a new todo',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
              ),
              Semantics(
                label: 'Add todo',
                hint: 'Add a new todo item to the list',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTodo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  label: 'Select due date',
                  hint: 'Choose a due date for the todo',
                  button: true,
                  child: TextButton(
                    onPressed: () => _selectDueDate(context),
                    child: Text(
                      _dueDate == null
                          ? 'Set Due Date'
                          : 'Due: ${_dueDate!.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Semantics(
                  label: 'Select category',
                  hint: 'Choose a category for the todo',
                  child: DropdownButton<String>(
                    value: _category,
                    hint: const Text('Category'),
                    isExpanded: true,
                    items: [null, ...categories]
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat ?? 'None'),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _category = value),
                    borderRadius: BorderRadius.circular(8),
                    underline: Container(
                      height: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  label: 'New category input',
                  hint: 'Enter a new custom category',
                  textField: true,
                  child: TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      hintText: 'New Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              Semantics(
                label: 'Add custom category',
                hint: 'Add a new custom category to the list',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addCustomCategory,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}