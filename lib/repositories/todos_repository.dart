import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo.dart';

/// Abstract repository interface for todos operations
abstract class TodosRepository {
  /// Get all todos from storage
  Future<List<Todo>> getAllTodos();

  /// Add a new todo to storage
  Future<void> addTodo(Todo todo);

  /// Update an existing todo in storage
  Future<void> updateTodo(Todo todo);

  /// Delete a todo from storage
  Future<void> deleteTodo(Todo todo);

  /// Watch for changes in todos
  Stream<List<Todo>> watchTodos();

  /// Get todos by category
  Future<List<Todo>> getTodosByCategory(TodoCategory category);

  /// Get completed todos
  Future<List<Todo>> getCompletedTodos();

  /// Get active (incomplete) todos
  Future<List<Todo>> getActiveTodos();

  /// Get overdue todos
  Future<List<Todo>> getOverdueTodos();
}

/// Hive implementation of TodosRepository
class HiveTodosRepository implements TodosRepository {
  static const String _boxName = 'todos';
  Box<Todo>? _todosBox;

  /// Initialize the repository by opening the Hive box
  Future<void> init() async {
    _todosBox = await Hive.openBox<Todo>(_boxName);
  }

  Box<Todo> get _box {
    if (_todosBox == null || !_todosBox!.isOpen) {
      throw Exception('TodosRepository not initialized. Call init() first.');
    }
    return _todosBox!;
  }

  @override
  Future<List<Todo>> getAllTodos() async {
    return _box.values.toList();
  }

  @override
  Future<void> addTodo(Todo todo) async {
    await _box.add(todo);
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    // Find the existing todo in the box by dateCreated (unique identifier)
    final existingTodo = _box.values.firstWhere(
      (t) => t.dateCreated == todo.dateCreated,
    );

    // Update the existing todo's fields
    existingTodo.title = todo.title;
    existingTodo.description = todo.description;
    existingTodo.isCompleted = todo.isCompleted;
    existingTodo.dueDate = todo.dueDate;
    existingTodo.priority = todo.priority;
    existingTodo.category = todo.category;
    existingTodo.subtasks = todo.subtasks;
    existingTodo.subtasksCompleted = todo.subtasksCompleted;
    existingTodo.reminderDateTime = todo.reminderDateTime;
    existingTodo.isRecurring = todo.isRecurring;
    existingTodo.recurringPattern = todo.recurringPattern;

    // Save the updated todo
    await existingTodo.save();
  }

  @override
  Future<void> deleteTodo(Todo todo) async {
    // Since Todo extends HiveObject, we can call delete() directly
    await todo.delete();
  }

  @override
  Stream<List<Todo>> watchTodos() {
    return _box.watch().map((_) => _box.values.toList());
  }

  @override
  Future<List<Todo>> getTodosByCategory(TodoCategory category) async {
    return _box.values
        .where((todo) => todo.category == category.index)
        .toList();
  }

  @override
  Future<List<Todo>> getCompletedTodos() async {
    return _box.values.where((todo) => todo.isCompleted).toList();
  }

  @override
  Future<List<Todo>> getActiveTodos() async {
    return _box.values.where((todo) => !todo.isCompleted).toList();
  }

  @override
  Future<List<Todo>> getOverdueTodos() async {
    final now = DateTime.now();
    return _box.values.where((todo) {
      if (todo.dueDate == null || todo.isCompleted) return false;
      return DateTime.fromMicrosecondsSinceEpoch(todo.dueDate!)
          .isBefore(now);
    }).toList();
  }

  /// Close the Hive box when done
  Future<void> dispose() async {
    await _todosBox?.close();
  }
}
