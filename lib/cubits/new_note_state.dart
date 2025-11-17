import 'package:equatable/equatable.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../models/note.dart';

class NewNoteState extends Equatable {
  final Note? note;
  final bool readOnly;
  final String title;
  final Document content;
  final List<String> tags;
  final DateTime? reminderDateTime;

  const NewNoteState({
    this.note,
    this.readOnly = false,
    this.title = '',
    required this.content,
    this.tags = const [],
    this.reminderDateTime,
  });

  NewNoteState copyWith({
    Note? note,
    bool? readOnly,
    String? title,
    Document? content,
    List<String>? tags,
    DateTime? reminderDateTime,
    bool clearReminder = false,
  }) {
    return NewNoteState(
      note: note ?? this.note,
      readOnly: readOnly ?? this.readOnly,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      reminderDateTime: clearReminder ? null : (reminderDateTime ?? this.reminderDateTime),
    );
  }

  bool get isNewNote => note == null;

  @override
  List<Object?> get props => [note, readOnly, title, content, tags, reminderDateTime];
}
