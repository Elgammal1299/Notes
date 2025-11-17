import 'package:hive/hive.dart';

part 'todo.g.dart';

/// Priority levels for ToDo items
enum TodoPriority {
  low,
  medium,
  high,
}

/// Category for ToDo items
enum TodoCategory {
  personal,
  work,
  shopping,
  health,
  other,
}

@HiveType(typeId: 1) // Note uses typeId: 0, so we use 1 for ToDo
class Todo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String? description;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  int dateCreated;

  @HiveField(4)
  int? dueDate;

  @HiveField(5)
  int priority; // 0: low, 1: medium, 2: high

  @HiveField(6)
  int category; // 0: personal, 1: work, 2: shopping, 3: health, 4: other

  @HiveField(7)
  List<String>? subtasks;

  @HiveField(8)
  List<bool>? subtasksCompleted;

  @HiveField(9)
  int? reminderDateTime;

  @HiveField(10)
  bool isRecurring;

  @HiveField(11)
  String? recurringPattern; // 'daily', 'weekly', 'monthly'

  Todo({
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.dateCreated,
    this.dueDate,
    this.priority = 1, // Default: medium
    this.category = 0, // Default: personal
    this.subtasks,
    this.subtasksCompleted,
    this.reminderDateTime,
    this.isRecurring = false,
    this.recurringPattern,
  });

  /// Get priority as enum
  TodoPriority get priorityEnum => TodoPriority.values[priority];

  /// Get category as enum
  TodoCategory get categoryEnum => TodoCategory.values[category];

  /// Check if todo is overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.fromMicrosecondsSinceEpoch(dueDate!)
        .isBefore(DateTime.now());
  }

  /// Get completion percentage for subtasks
  double get completionPercentage {
    if (subtasks == null || subtasks!.isEmpty) return 0.0;
    if (subtasksCompleted == null) return 0.0;

    final completed =
        subtasksCompleted!.where((completed) => completed).length;
    return completed / subtasks!.length;
  }

  /// Toggle todo completion
  void toggleCompletion() {
    isCompleted = !isCompleted;
    save();
  }

  /// Toggle subtask completion
  void toggleSubtask(int index) {
    if (subtasksCompleted == null || index >= subtasksCompleted!.length) {
      return;
    }
    subtasksCompleted![index] = !subtasksCompleted![index];
    save();
  }

  /// Add a new subtask
  void addSubtask(String subtask) {
    subtasks ??= [];
    subtasksCompleted ??= [];
    subtasks!.add(subtask);
    subtasksCompleted!.add(false);
    save();
  }

  /// Remove a subtask
  void removeSubtask(int index) {
    if (subtasks == null || index >= subtasks!.length) return;
    subtasks!.removeAt(index);
    subtasksCompleted!.removeAt(index);
    save();
  }

  /// Create a copy of the todo
  Todo copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    int? dateCreated,
    int? dueDate,
    int? priority,
    int? category,
    List<String>? subtasks,
    List<bool>? subtasksCompleted,
    int? reminderDateTime,
    bool? isRecurring,
    String? recurringPattern,
  }) {
    return Todo(
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dateCreated: dateCreated ?? this.dateCreated,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      subtasks: subtasks ?? this.subtasks,
      subtasksCompleted: subtasksCompleted ?? this.subtasksCompleted,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
    );
  }
}
