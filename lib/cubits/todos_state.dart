import 'package:equatable/equatable.dart';
import '../models/todo.dart';

/// Filter options for todos
enum TodoFilter {
  all,
  active,
  completed,
  overdue,
}

class TodosState extends Equatable {
  final List<Todo> todos;
  final TodoFilter filter;
  final TodoCategory? categoryFilter;
  final String searchTerm;
  final bool showCompletedTasks;

  const TodosState({
    this.todos = const [],
    this.filter = TodoFilter.all,
    this.categoryFilter,
    this.searchTerm = '',
    this.showCompletedTasks = true,
  });

  TodosState copyWith({
    List<Todo>? todos,
    TodoFilter? filter,
    TodoCategory? categoryFilter,
    bool clearCategoryFilter = false,
    String? searchTerm,
    bool? showCompletedTasks,
  }) {
    return TodosState(
      todos: todos ?? this.todos,
      filter: filter ?? this.filter,
      categoryFilter: clearCategoryFilter ? null : (categoryFilter ?? this.categoryFilter),
      searchTerm: searchTerm ?? this.searchTerm,
      showCompletedTasks: showCompletedTasks ?? this.showCompletedTasks,
    );
  }

  @override
  List<Object?> get props => [
        todos,
        filter,
        categoryFilter,
        searchTerm,
        showCompletedTasks,
      ];
}
