import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/todo.dart';
import '../../viewmodels/todo_viewmodel.dart';

class TodoItem extends ConsumerStatefulWidget {
  final Todo todo;
  const TodoItem({super.key, required this.todo});

  @override
  ConsumerState<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends ConsumerState<TodoItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _editController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isEditing = false;
  DateTime? _dueDate;
  String? _category;

  @override
  void initState() {
    super.initState();
    _editController.text = widget.todo.title;
    _dueDate = widget.todo.dueDate;
    _category = widget.todo.category;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    if (widget.todo.isCompleted) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _editController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
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

    return Dismissible(
      key: ValueKey(widget.todo.id),
      onDismissed: (direction) {
        ref.read(todoViewModelProvider.notifier).deleteTodo(widget.todo.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.todo.title} deleted')),
        );
      },
      background: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Semantics(
        label: 'Todo item: ${widget.todo.title}',
        child: ListTile(
          key: ValueKey(widget.todo.id),
          leading: Semantics(
            label: 'Toggle todo completion',
            hint: widget.todo.isCompleted ? 'Mark as incomplete' : 'Mark as completed',
            checked: widget.todo.isCompleted,
            child: Checkbox(
              value: widget.todo.isCompleted,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (value) {
                ref.read(todoViewModelProvider.notifier).toggleTodo(widget.todo.id);
                if (value!) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              },
            ),
          ),
          title: _isEditing
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      label: 'Edit todo title',
                      hint: 'Modify the todo item title',
                      textField: true,
                      child: TextField(
                        controller: _editController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        onSubmitted: (_) {},
                      ),
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
                )
              : FadeTransition(
                  opacity: _animation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.todo.title,
                        style: TextStyle(
                          decoration: widget.todo.isCompleted ? TextDecoration.lineThrough : null,
                          color: widget.todo.isCompleted
                              ? Theme.of(context).colorScheme.onSurface.withValues()
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (widget.todo.dueDate != null || widget.todo.category != null)
                        Text(
                          '${widget.todo.dueDate != null ? 'Due: ${widget.todo.dueDate!.toLocal().toString().split(' ')[0]}' : ''}'
                          '${widget.todo.dueDate != null && widget.todo.category != null ? ' | ' : ''}'
                          '${widget.todo.category != null ? 'Category: ${widget.todo.category}' : ''}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(),
                              ),
                        ),
                    ],
                  ),
                ),
          trailing: Semantics(
            label: _isEditing ? 'Save todo edit' : 'Edit todo',
            hint: _isEditing ? 'Save changes to todo item' : 'Edit todo item title',
            button: true,
            child: IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                if (_isEditing && _editController.text.trim().isNotEmpty) {
                  ref.read(todoViewModelProvider.notifier).editTodo(
                        widget.todo.id,
                        _editController.text.trim(),
                        dueDate: _dueDate,
                        category: _category,
                      );
                } else if (_isEditing) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Todo cannot be empty')),
                  );
                  return;
                }
                setState(() => _isEditing = !_isEditing);
              },
            ),
          ),
        ),
      ),
    );
  }
}