import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/todo.dart';
import '../repositories/todos_repository.dart';
import '../services/notification_service.dart';
import 'todos_state.dart';

/// Cubit for managing To-Do list state
class TodosCubit extends Cubit<TodosState> {
  final TodosRepository _repository;
  final NotificationService _notificationService = NotificationService();

  TodosCubit(this._repository) : super(const TodosState()) {
    loadTodos();
  }

  /// Load all todos from repository
  Future<void> loadTodos() async {
    try {
      final todos = await _repository.getAllTodos();
      emit(state.copyWith(todos: todos));
    } catch (_) {}
  }

  /// Add a new todo
  Future<void> addTodo(Todo todo) async {
    try {
      await _repository.addTodo(todo);
      if (todo.reminderDateTime != null) {
        await _scheduleNotification(todo);
      }
      await loadTodos();
    } catch (_) {}
  }

  /// Update an existing todo
  Future<void> updateTodo(Todo todo) async {
    try {
      await _repository.updateTodo(todo);
      if (todo.reminderDateTime != null) {
        await _scheduleNotification(todo);
      } else {
        await _notificationService.cancelNoteReminder(
          _todoToNoteForNotification(todo),
        );
      }
      await loadTodos();
    } catch (_) {}
  }

  /// Delete a todo
  Future<void> deleteTodo(Todo todo) async {
    try {
      if (todo.reminderDateTime != null) {
        await _notificationService.cancelNoteReminder(
          _todoToNoteForNotification(todo),
        );
      }
      await _repository.deleteTodo(todo);
      await loadTodos();
    } catch (_) {}
  }

  /// Toggle todo completion status
  Future<void> toggleTodoCompletion(Todo todo) async {
    try {
      final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
      await updateTodo(updatedTodo);
    } catch (_) {}
  }

  /// Toggle subtask completion status
  Future<void> toggleSubtask(Todo todo, int subtaskIndex) async {
    try {
      if (todo.subtasksCompleted == null ||
          subtaskIndex >= todo.subtasksCompleted!.length) {
        return;
      }
      final updatedCompleted = List<bool>.from(todo.subtasksCompleted!);
      updatedCompleted[subtaskIndex] = !updatedCompleted[subtaskIndex];
      final updatedTodo = todo.copyWith(subtasksCompleted: updatedCompleted);
      await updateTodo(updatedTodo);
    } catch (_) {}
  }

  /// Set filter for todos
  void setFilter(TodoFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  /// Set category filter
  void setCategoryFilter(TodoCategory? category) {
    if (category == null) {
      emit(state.copyWith(clearCategoryFilter: true));
    } else {
      emit(state.copyWith(categoryFilter: category));
    }
  }

  /// Set search term
  void setSearchTerm(String searchTerm) {
    emit(state.copyWith(searchTerm: searchTerm));
  }

  /// Toggle show completed tasks
  void toggleShowCompletedTasks() {
    emit(state.copyWith(showCompletedTasks: !state.showCompletedTasks));
  }

  /// Get filtered todos based on current state
  List<Todo> getFilteredTodos() {
    List<Todo> filtered = List.from(state.todos);

    // Apply search filter
    if (state.searchTerm.isNotEmpty) {
      filtered = filtered.where((todo) {
        final titleMatch = todo.title.toLowerCase().contains(
              state.searchTerm.toLowerCase(),
            );
        final descriptionMatch = todo.description?.toLowerCase().contains(
                  state.searchTerm.toLowerCase(),
                ) ??
            false;
        return titleMatch || descriptionMatch;
      }).toList();
    }

    // Apply category filter
    if (state.categoryFilter != null) {
      filtered = filtered.where((todo) {
        return todo.category == state.categoryFilter!.index;
      }).toList();
    }

    // Apply completion filter
    if (!state.showCompletedTasks) {
      filtered = filtered.where((todo) => !todo.isCompleted).toList();
    }

    // Apply status filter
    switch (state.filter) {
      case TodoFilter.all:
        break;
      case TodoFilter.active:
        filtered = filtered.where((todo) => !todo.isCompleted).toList();
        break;
      case TodoFilter.completed:
        filtered = filtered.where((todo) => todo.isCompleted).toList();
        break;
      case TodoFilter.overdue:
        final now = DateTime.now();
        filtered = filtered.where((todo) {
          if (todo.dueDate == null || todo.isCompleted) return false;
          return DateTime.fromMicrosecondsSinceEpoch(todo.dueDate!)
              .isBefore(now);
        }).toList();
        break;
    }

    // Sort: completed → priority → due date → creation date
    filtered.sort((a, b) {
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;

      final priorityCompare = b.priority.compareTo(a.priority);
      if (priorityCompare != 0) return priorityCompare;

      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;

      return b.dateCreated.compareTo(a.dateCreated);
    });

    return filtered;
  }

  /// Get todos count by filter
  int getTodosCount(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all:
        return state.todos.length;
      case TodoFilter.active:
        return state.todos.where((todo) => !todo.isCompleted).length;
      case TodoFilter.completed:
        return state.todos.where((todo) => todo.isCompleted).length;
      case TodoFilter.overdue:
        final now = DateTime.now();
        return state.todos.where((todo) {
          if (todo.dueDate == null || todo.isCompleted) return false;
          return DateTime.fromMicrosecondsSinceEpoch(todo.dueDate!)
              .isBefore(now);
        }).length;
    }
  }

  /// Schedule notification for a todo
  Future<void> _scheduleNotification(Todo todo) async {
    try {
      if (todo.reminderDateTime == null) return;
      final scheduledTime = DateTime.fromMicrosecondsSinceEpoch(
        todo.reminderDateTime!,
      );
      final noteForNotification = _todoToNoteForNotification(todo);
      await _notificationService.scheduleNoteReminder(
        note: noteForNotification,
        scheduledTime: scheduledTime,
      );
    } catch (_) {}
  }

  /// Convert Todo to a temporary Note object for notification purposes
  dynamic _todoToNoteForNotification(Todo todo) {
    return _MockNoteForNotification(
      title: todo.title,
      content: todo.description ?? 'Todo reminder',
      dateCreated: todo.dateCreated,
    );
  }

  /// Clear all completed todos
  Future<void> clearCompletedTodos() async {
    try {
      final completedTodos = state.todos.where((todo) => todo.isCompleted);
      for (final todo in completedTodos) {
        await _repository.deleteTodo(todo);
      }
      await loadTodos();
    } catch (_) {}
  }
}

/// Mock Note class for notification purposes
class _MockNoteForNotification {
  final String title;
  final String? content;
  final int dateCreated;

  _MockNoteForNotification({
    required this.title,
    required this.content,
    required this.dateCreated,
  });
}
