import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../core/constants.dart';
import '../cubits/todos_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/todo.dart';
import '../widgets/note_icon_button_outlined.dart';
import '../widgets/banner_ad_widget.dart';
import '../services/ad_helper.dart';

class AddOrEditTodoPage extends StatefulWidget {
  final Todo? todo;
  final bool isNewTodo;

  const AddOrEditTodoPage({
    super.key,
    this.todo,
    this.isNewTodo = true,
  });

  @override
  State<AddOrEditTodoPage> createState() => _AddOrEditTodoPageState();
}

class _AddOrEditTodoPageState extends State<AddOrEditTodoPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _subtaskController;

  late TodoPriority _selectedPriority;
  late TodoCategory _selectedCategory;
  DateTime? _dueDate;
  DateTime? _reminderDateTime;
  bool _isRecurring = false;
  String? _recurringPattern;
  List<String> _subtasks = [];
  List<bool> _subtasksCompleted = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(text: widget.todo?.description ?? '');
    _subtaskController = TextEditingController();

    _selectedPriority = widget.todo?.priorityEnum ?? TodoPriority.medium;
    _selectedCategory = widget.todo?.categoryEnum ?? TodoCategory.personal;
    _dueDate = widget.todo?.dueDate != null
        ? DateTime.fromMicrosecondsSinceEpoch(widget.todo!.dueDate!)
        : null;
    _reminderDateTime = widget.todo?.reminderDateTime != null
        ? DateTime.fromMicrosecondsSinceEpoch(widget.todo!.reminderDateTime!)
        : null;
    _isRecurring = widget.todo?.isRecurring ?? false;
    _recurringPattern = widget.todo?.recurringPattern;
    _subtasks = widget.todo?.subtasks != null ? List.from(widget.todo!.subtasks!) : [];
    _subtasksCompleted = widget.todo?.subtasksCompleted != null
        ? List.from(widget.todo!.subtasksCompleted!)
        : [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  bool get _canSave {
    return _titleController.text.trim().isNotEmpty;
  }

  void _saveTodo() {
    if (!_canSave) return;

    final now = DateTime.now();
    final todo = Todo(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      isCompleted: widget.todo?.isCompleted ?? false,
      dateCreated: widget.todo?.dateCreated ?? now.microsecondsSinceEpoch,
      dueDate: _dueDate?.microsecondsSinceEpoch,
      priority: _selectedPriority.index,
      category: _selectedCategory.index,
      subtasks: _subtasks.isEmpty ? null : _subtasks,
      subtasksCompleted: _subtasksCompleted.isEmpty ? null : _subtasksCompleted,
      reminderDateTime: _reminderDateTime?.microsecondsSinceEpoch,
      isRecurring: _isRecurring,
      recurringPattern: _recurringPattern,
    );

    final cubit = context.read<TodosCubit>();
    if (widget.isNewTodo) {
      cubit.addTodo(todo);
      // Show Video Ad for new Todo
      AdHelper.showRewardedAd(onUserEarnedReward: () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      // For existing todos, we need to preserve the HiveObject reference
      final existingTodo = widget.todo!;
      existingTodo.title = todo.title;
      existingTodo.description = todo.description;
      existingTodo.dueDate = todo.dueDate;
      existingTodo.priority = todo.priority;
      existingTodo.category = todo.category;
      existingTodo.subtasks = todo.subtasks;
      existingTodo.subtasksCompleted = todo.subtasksCompleted;
      existingTodo.reminderDateTime = todo.reminderDateTime;
      existingTodo.isRecurring = todo.isRecurring;
      existingTodo.recurringPattern = todo.recurringPattern;
      cubit.updateTodo(existingTodo);
      Navigator.pop(context);
    }

  }

  void _deleteTodo() {
    if (widget.isNewTodo) return;

    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.deleteTodo),
          content: Text(l10n.deleteTodoConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                context.read<TodosCubit>().deleteTodo(widget.todo!);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close edit page
              },
              child: Text(l10n.yes, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: mounted ? context : context,
        initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _selectReminderDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminderDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: mounted ? context : context,
        initialTime: TimeOfDay.fromDateTime(_reminderDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _reminderDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _addSubtask() {
    if (_subtaskController.text.trim().isEmpty) return;

    setState(() {
      _subtasks.add(_subtaskController.text.trim());
      _subtasksCompleted.add(false);
      _subtaskController.clear();
    });
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
      _subtasksCompleted.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewTodo ? l10n.newTodo : l10n.editTodo),
        actions: [
          if (!widget.isNewTodo)
            NoteIconButtonOutlined(
              icon: FontAwesomeIcons.trash,
              onPressed: _deleteTodo,
            ),
          NoteIconButtonOutlined(
            icon: FontAwesomeIcons.check,
            onPressed: _canSave ? _saveTodo : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: l10n.todoTitle,
                      hintText: l10n.todoTitleHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(FontAwesomeIcons.heading),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.todoDescription,
                      hintText: l10n.todoDescriptionHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(FontAwesomeIcons.alignLeft),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 24),

                  // Priority
                  _SectionTitle(title: l10n.priority),
                  const SizedBox(height: 8),
                  SegmentedButton<TodoPriority>(
                    segments: [
                      ButtonSegment(
                        value: TodoPriority.low,
                        label: Text(l10n.lowPriority),
                        icon: const Icon(FontAwesomeIcons.arrowDown, size: 16),
                      ),
                      ButtonSegment(
                        value: TodoPriority.medium,
                        label: Text(l10n.mediumPriority),
                        icon: const Icon(FontAwesomeIcons.equals, size: 16),
                      ),
                      ButtonSegment(
                        value: TodoPriority.high,
                        label: Text(l10n.highPriority),
                        icon: const Icon(FontAwesomeIcons.arrowUp, size: 16),
                      ),
                    ],
                    selected: {_selectedPriority},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _selectedPriority = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Category
                  _SectionTitle(title: l10n.category),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TodoCategory.values.map((category) {
                      final isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getCategoryIcon(category), size: 16),
                            const SizedBox(width: 8),
                            Text(_getCategoryName(category)),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        selectedColor: primary.withValues(alpha: 0.3),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Due Date
                  _SectionTitle(title: l10n.dueDate),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDueDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(FontAwesomeIcons.calendar, color: primary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _dueDate != null
                                  ? DateFormat('MMM dd, yyyy - hh:mm a').format(_dueDate!)
                                  : l10n.selectDueDate,
                              style: TextStyle(
                                fontSize: 16,
                                color: _dueDate != null ? Colors.black87 : Colors.grey,
                              ),
                            ),
                          ),
                          if (_dueDate != null)
                            IconButton(
                              icon: const Icon(FontAwesomeIcons.xmark, size: 16),
                              onPressed: () {
                                setState(() {
                                  _dueDate = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reminder
                  _SectionTitle(title: l10n.reminder),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectReminderDateTime,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(FontAwesomeIcons.bell, color: primary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _reminderDateTime != null
                                  ? DateFormat('MMM dd, yyyy - hh:mm a')
                                      .format(_reminderDateTime!)
                                  : l10n.noReminderSet,
                              style: TextStyle(
                                fontSize: 16,
                                color: _reminderDateTime != null
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          if (_reminderDateTime != null)
                            IconButton(
                              icon: const Icon(FontAwesomeIcons.xmark, size: 16),
                              onPressed: () {
                                setState(() {
                                  _reminderDateTime = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recurring
                  Row(
                    children: [
                      Expanded(child: _SectionTitle(title: l10n.recurringTask)),
                      Switch(
                        value: _isRecurring,
                        onChanged: (value) {
                          setState(() {
                            _isRecurring = value;
                            if (!value) _recurringPattern = null;
                          });
                        },
                        activeTrackColor: primary,
                      ),
                    ],
                  ),
                  if (_isRecurring) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _recurringPattern,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(FontAwesomeIcons.rotate),
                      ),
                      hint: Text(l10n.selectPattern),
                      items: [
                        DropdownMenuItem(value: 'daily', child: Text(l10n.daily)),
                        DropdownMenuItem(value: 'weekly', child: Text(l10n.weekly)),
                        DropdownMenuItem(value: 'monthly', child: Text(l10n.monthly)),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _recurringPattern = value;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Subtasks
                  _SectionTitle(title: l10n.subtasks),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _subtaskController,
                          decoration: InputDecoration(
                            hintText: l10n.addSubtask,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(FontAwesomeIcons.listCheck),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _addSubtask(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _addSubtask,
                        icon: const Icon(FontAwesomeIcons.plus),
                        style: IconButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_subtasks.isNotEmpty)
                    ...List.generate(_subtasks.length, (index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Checkbox(
                            value: _subtasksCompleted[index],
                            onChanged: (value) {
                              setState(() {
                                _subtasksCompleted[index] = value ?? false;
                              });
                            },
                          ),
                          title: Text(
                            _subtasks[index],
                            style: TextStyle(
                              decoration: _subtasksCompleted[index]
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(FontAwesomeIcons.trash, size: 16),
                            onPressed: () => _removeSubtask(index),
                            color: Colors.red,
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          BannerAdWidget(customAdUnitId: AdHelper.bannerAdUnitId2),
        ],
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

  String _getCategoryName(TodoCategory category) {
    final l10n = AppLocalizations.of(context);
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
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
    );
  }
}
