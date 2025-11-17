import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/extensions.dart';
import '../enums/order_option.dart';
import '../models/note.dart';
import '../repositories/notes_repository.dart';
import 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this._notesRepository) : super(const NotesState()) {
    _loadNotes();
  }

  final NotesRepository _notesRepository;

  /// Load all notes from repository
  Future<void> _loadNotes() async {
    final notes = await _notesRepository.getAllNotes();
    emit(state.copyWith(notes: notes));
  }

  List<Note> get filteredNotes {
    final allNotes = state.notes;
    final searchTerm = state.searchTerm;

    final filtered = searchTerm.isEmpty
        ? List<Note>.from(allNotes)
        : allNotes.where((note) => _test(note, searchTerm)).toList();

    filtered.sort((note1, note2) => _compare(note1, note2));

    return filtered;
  }

  bool _test(Note note, String searchTerm) {
    final term = searchTerm.toLowerCase().trim();
    final title = note.title?.toLowerCase() ?? '';
    final content = note.content?.toLowerCase() ?? '';
    final tags = note.tags?.map((e) => e.toLowerCase()).toList() ?? [];
    return title.contains(term) ||
        content.contains(term) ||
        tags.deepContains(term);
  }

  int _compare(Note note1, Note note2) {
    return state.orderBy == OrderOption.dateModified
        ? state.isDescending
            ? note2.dateModified.compareTo(note1.dateModified)
            : note1.dateModified.compareTo(note2.dateModified)
        : state.isDescending
            ? note2.dateCreated.compareTo(note1.dateCreated)
            : note1.dateCreated.compareTo(note2.dateCreated);
  }

  Future<void> addNote(Note note) async {
    await _notesRepository.addNote(note);
    await _loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await _notesRepository.updateNote(note);
    await _loadNotes();
  }

  Future<void> deleteNote(Note note) async {
    await _notesRepository.deleteNote(note);
    await _loadNotes();
  }

  void setOrderBy(OrderOption orderBy) {
    emit(state.copyWith(orderBy: orderBy));
  }

  void setIsDescending(bool isDescending) {
    emit(state.copyWith(isDescending: isDescending));
  }

  void setIsGrid(bool isGrid) {
    emit(state.copyWith(isGrid: isGrid));
  }

  void setSearchTerm(String searchTerm) {
    emit(state.copyWith(searchTerm: searchTerm));
  }
}
