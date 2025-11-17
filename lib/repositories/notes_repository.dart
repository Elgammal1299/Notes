import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';

/// Abstract repository interface for notes operations
/// This allows for easy testing and switching implementations
abstract class NotesRepository {
  /// Get all notes from storage
  Future<List<Note>> getAllNotes();

  /// Add a new note to storage
  Future<void> addNote(Note note);

  /// Update an existing note in storage
  Future<void> updateNote(Note note);

  /// Delete a note from storage
  Future<void> deleteNote(Note note);

  /// Watch for changes in notes
  Stream<List<Note>> watchNotes();
}

/// Hive implementation of NotesRepository
class HiveNotesRepository implements NotesRepository {
  static const String _boxName = 'notes';
  Box<Note>? _notesBox;

  /// Initialize the repository by opening the Hive box
  Future<void> init() async {
    _notesBox = await Hive.openBox<Note>(_boxName);
  }

  Box<Note> get _box {
    if (_notesBox == null || !_notesBox!.isOpen) {
      throw Exception('NotesRepository not initialized. Call init() first.');
    }
    return _notesBox!;
  }

  @override
  Future<List<Note>> getAllNotes() async {
    return _box.values.toList();
  }

  @override
  Future<void> addNote(Note note) async {
    await _box.add(note);
  }

  @override
  Future<void> updateNote(Note note) async {
    // Find the existing note in the box by dateCreated (unique identifier)
    final existingNote = _box.values.firstWhere(
      (n) => n.dateCreated == note.dateCreated,
    );

    // Update the existing note's fields
    existingNote.title = note.title;
    existingNote.content = note.content;
    existingNote.contentJson = note.contentJson;
    existingNote.dateModified = note.dateModified;
    existingNote.tags = note.tags;
    existingNote.reminderDateTime = note.reminderDateTime;

    // Save the updated note
    await existingNote.save();
  }

  @override
  Future<void> deleteNote(Note note) async {
    // Since Note extends HiveObject, we can call delete() directly
    await note.delete();
  }

  @override
  Stream<List<Note>> watchNotes() {
    return _box.watch().map((_) => _box.values.toList());
  }

  /// Close the Hive box when done
  Future<void> dispose() async {
    await _notesBox?.close();
  }
}
