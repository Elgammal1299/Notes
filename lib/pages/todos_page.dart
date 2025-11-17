import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/constants.dart';
import '../cubits/todos_cubit.dart';
import '../cubits/todos_state.dart';
import '../l10n/app_localizations.dart';
import '../models/todo.dart';
import 'add_or_edit_todo_page.dart';

class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todos),
        actions: [
          // Filter menu
          PopupMenuButton<TodoFilter>(
            icon: const Icon(FontAwesomeIcons.filter, color: primary),
            onSelected: (filter) {
              context.read<TodosCubit>().setFilter(filter);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: TodoFilter.all,
                child: Row(
                  children: [
                    const Icon(FontAwesomeIcons.list, size: 16),
                    const SizedBox(width: 8),
                    Text(l10n.all),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TodoFilter.active,
                child: Row(
                  children: [
                    const Icon(FontAwesomeIcons.circleCheck, size: 16),
                    const SizedBox(width: 8),
                    Text(l10n.active),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TodoFilter.completed,
                child: Row(
                  children: [
                    const Icon(FontAwesomeIcons.check, size: 16),
                    const SizedBox(width: 8),
                    Text(l10n.completed),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TodoFilter.overdue,
                child: Row(
                  children: [
                    const Icon(FontAwesomeIcons.triangleExclamation, size: 16),
                    const SizedBox(width: 8),
                    Text(l10n.overdue),
                  ],
                ),
              ),
            ],
          ),
          // Category filter menu
          PopupMenuButton<TodoCategory?>(
            icon: const Icon(FontAwesomeIcons.tag, color: primary),
            onSelected: (category) {
              context.read<TodosCubit>().setCategoryFilter(category);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: null,
                child: Row(
                  children: [
                    const Icon(FontAwesomeIcons.asterisk, size: 16),
                    const SizedBox(width: 8),
                    Text(l10n.allCategories),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              ...TodoCategory.values.map((category) {
                return PopupMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(_getCategoryIcon(category), size: 16),
                      const SizedBox(width: 8),
                      Text(_getCategoryName(context, category)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
      body: BlocBuilder<TodosCubit, TodosState>(
        builder: (context, state) {
          final cubit = context.read<TodosCubit>();
          final filteredTodos = cubit.getFilteredTodos();

          if (filteredTodos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.listCheck,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noTodosFound,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter chips
              if (state.filter != TodoFilter.all ||
                  state.categoryFilter != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (state.filter != TodoFilter.all)
                        Chip(
                          label: Text(_getFilterName(context, state.filter)),
                          onDeleted: () {
                            cubit.setFilter(TodoFilter.all);
                          },
                          deleteIcon: const Icon(FontAwesomeIcons.xmark, size: 14),
                        ),
                      if (state.categoryFilter != null)
                        Chip(
                          label: Text(_getCategoryName(context, state.categoryFilter!)),
                          onDeleted: () {
                            cubit.setCategoryFilter(null);
                          },
                          deleteIcon: const Icon(FontAwesomeIcons.xmark, size: 14),
                        ),
                    ],
                  ),
                ),
              // Todos list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTodos.length,
                  itemBuilder: (context, index) {
                    final todo = filteredTodos[index];
                    return _TodoItemCard(todo: todo);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddOrEditTodoPage(isNewTodo: true),
            ),
          );
        },
        backgroundColor: primary,
        child: const Icon(FontAwesomeIcons.plus, color: Colors.white),
      ),
    );
  }

  IconData _getCategoryIcon(TodoCategory category) {
    switch (category) {
      case TodoCategory.personal:
        return FontAwesomeIcons.user;
      case TodoCategory.work:
        return FontAwesomeIcons.briefcase;
      case TodoCategory.shopping:
        return FontAwesomeIcons.cartShopping;
      case TodoCategory.health:
        return FontAwesomeIcons.heartPulse;
      case TodoCategory.other:
        return FontAwesomeIcons.ellipsis;
    }
  }

  String _getCategoryName(BuildContext context, TodoCategory category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case TodoCategory.personal:
        return l10n.personal;
      case TodoCategory.work:
        return l10n.work;
      case TodoCategory.shopping:
        return l10n.shopping;
      case TodoCategory.health:
        return l10n.health;
      case TodoCategory.other:
        return l10n.other;
    }
  }

  String _getFilterName(BuildContext context, TodoFilter filter) {
    final l10n = AppLocalizations.of(context)!;
    switch (filter) {
      case TodoFilter.all:
        return l10n.all;
      case TodoFilter.active:
        return l10n.active;
      case TodoFilter.completed:
        return l10n.completed;
      case TodoFilter.overdue:
        return l10n.overdue;
    }
  }
}

class _TodoItemCard extends StatelessWidget {
  final Todo todo;

  const _TodoItemCard({required this.todo});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<TodosCubit>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: todo.isOverdue ? Colors.red.shade200 : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddOrEditTodoPage(
                todo: todo,
                isNewTodo: false,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: todo.isCompleted,
                    onChanged: (_) {
                      cubit.toggleTodoCompletion(todo);
                    },
                    activeColor: primary,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: todo.isCompleted
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),
                        if (todo.description != null &&
                            todo.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            todo.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Priority indicator
                  _PriorityIndicator(priority: todo.priorityEnum),
                ],
              ),
              // Tags row
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  // Category chip
                  _CategoryChip(category: todo.categoryEnum),
                  // Due date chip
                  if (todo.dueDate != null)
                    _DueDateChip(
                      dueDate: DateTime.fromMicrosecondsSinceEpoch(todo.dueDate!),
                      isOverdue: todo.isOverdue,
                      isCompleted: todo.isCompleted,
                    ),
                  // Reminder chip
                  if (todo.reminderDateTime != null)
                    Chip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(FontAwesomeIcons.bell, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            l10n.reminder,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  // Recurring chip
                  if (todo.isRecurring)
                    Chip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(FontAwesomeIcons.rotate, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            todo.recurringPattern ?? l10n.recurring,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              // Subtasks progress
              if (todo.subtasks != null && todo.subtasks!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.listCheck,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: todo.completionPercentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation(primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(todo.completionPercentage * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityIndicator extends StatelessWidget {
  final TodoPriority priority;

  const _PriorityIndicator({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (priority) {
      case TodoPriority.low:
        color = Colors.blue;
        icon = FontAwesomeIcons.arrowDown;
        break;
      case TodoPriority.medium:
        color = Colors.orange;
        icon = FontAwesomeIcons.equals;
        break;
      case TodoPriority.high:
        color = Colors.red;
        icon = FontAwesomeIcons.arrowUp;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final TodoCategory category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    IconData icon;
    String label;

    switch (category) {
      case TodoCategory.personal:
        icon = FontAwesomeIcons.user;
        label = l10n.personal;
        break;
      case TodoCategory.work:
        icon = FontAwesomeIcons.briefcase;
        label = l10n.work;
        break;
      case TodoCategory.shopping:
        icon = FontAwesomeIcons.cartShopping;
        label = l10n.shopping;
        break;
      case TodoCategory.health:
        icon = FontAwesomeIcons.heartPulse;
        label = l10n.health;
        break;
      case TodoCategory.other:
        icon = FontAwesomeIcons.ellipsis;
        label = l10n.other;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _DueDateChip extends StatelessWidget {
  final DateTime dueDate;
  final bool isOverdue;
  final bool isCompleted;

  const _DueDateChip({
    required this.dueDate,
    required this.isOverdue,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    String label;
    Color? backgroundColor;
    Color? textColor;

    if (isCompleted) {
      label = l10n.formatDate(dueDate);
      backgroundColor = Colors.grey[200];
      textColor = Colors.grey[700];
    } else if (isOverdue) {
      label = l10n.overdue;
      backgroundColor = Colors.red[100];
      textColor = Colors.red[900];
    } else if (difference.inDays == 0) {
      label = l10n.today;
      backgroundColor = Colors.orange[100];
      textColor = Colors.orange[900];
    } else if (difference.inDays == 1) {
      label = l10n.tomorrow;
      backgroundColor = Colors.blue[100];
      textColor = Colors.blue[900];
    } else {
      label = l10n.formatDate(dueDate);
      backgroundColor = Colors.grey[200];
      textColor = Colors.grey[700];
    }

    return Chip(
      avatar: Icon(
        FontAwesomeIcons.calendar,
        size: 14,
        color: textColor,
      ),
      label: Text(
        label,
        style: TextStyle(fontSize: 11, color: textColor),
      ),
      backgroundColor: backgroundColor,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
