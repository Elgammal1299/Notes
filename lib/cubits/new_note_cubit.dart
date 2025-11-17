import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../models/note.dart';
import 'new_note_state.dart';

class NewNoteCubit extends Cubit<NewNoteState> {
  NewNoteCubit() : super(NewNoteState(content: Document()));

  void setNote(Note note) {
    emit(state.copyWith(
      note: note,
      title: note.title ?? '',
      content: Document.fromJson(jsonDecode(note.contentJson)),
      tags: note.tags ?? [],
      reminderDateTime: note.reminderDateTime != null
          ? DateTime.fromMicrosecondsSinceEpoch(note.reminderDateTime!)
          : null,
    ));
  }

  void setReminderDateTime(DateTime? dateTime) {
    emit(state.copyWith(reminderDateTime: dateTime));
  }

  void removeReminder() {
    emit(state.copyWith(reminderDateTime: null, clearReminder: true));
  }

  void setReadOnly(bool readOnly) {
    emit(state.copyWith(readOnly: readOnly));
  }

  void setTitle(String title) {
    emit(state.copyWith(title: title));
  }

  void setContent(Document content) {
    emit(state.copyWith(content: content));
  }

  void addTag(String tag) {
    final updatedTags = List<String>.from(state.tags)..add(tag);
    emit(state.copyWith(tags: updatedTags));
  }

  void removeTag(int index) {
    final updatedTags = List<String>.from(state.tags)..removeAt(index);
    emit(state.copyWith(tags: updatedTags));
  }

  void updateTag(String tag, int index) {
    final updatedTags = List<String>.from(state.tags);
    updatedTags[index] = tag;
    emit(state.copyWith(tags: updatedTags));
  }

  bool canSaveNote() {
    final String? newTitle = state.title.trim().isNotEmpty ? state.title.trim() : null;
    final String? newContent = state.content.toPlainText().trim().isNotEmpty
        ? state.content.toPlainText().trim()
        : null;

    bool canSave = newTitle != null || newContent != null;

    if (!state.isNewNote) {
      final newContentJson = jsonEncode(state.content.toDelta().toJson());
      final oldReminder = state.note!.reminderDateTime;
      final newReminder = state.reminderDateTime?.microsecondsSinceEpoch;

      canSave = canSave &&
          (newTitle != state.note!.title ||
              newContentJson != state.note!.contentJson ||
              !listEquals(state.tags, state.note!.tags) ||
              oldReminder != newReminder);
    }

    return canSave;
  }

  Note buildNote() {
    final String? newTitle = state.title.trim().isNotEmpty ? state.title.trim() : null;
    final String? newContent = state.content.toPlainText().trim().isNotEmpty
        ? state.content.toPlainText().trim()
        : null;
    final String contentJson = jsonEncode(state.content.toDelta().toJson());
    final int now = DateTime.now().microsecondsSinceEpoch;

    return Note(
      title: newTitle,
      content: newContent,
      contentJson: contentJson,
      dateCreated: state.isNewNote ? now : state.note!.dateCreated,
      dateModified: now,
      tags: state.tags,
    )..reminderDateTime = state.reminderDateTime?.microsecondsSinceEpoch;
  }
}
