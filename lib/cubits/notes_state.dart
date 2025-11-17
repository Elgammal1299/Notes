import 'package:equatable/equatable.dart';

import '../enums/order_option.dart';
import '../models/note.dart';

class NotesState extends Equatable {
  final List<Note> notes;
  final OrderOption orderBy;
  final bool isDescending;
  final bool isGrid;
  final String searchTerm;

  const NotesState({
    this.notes = const [],
    this.orderBy = OrderOption.dateModified,
    this.isDescending = true,
    this.isGrid = true,
    this.searchTerm = '',
  });

  NotesState copyWith({
    List<Note>? notes,
    OrderOption? orderBy,
    bool? isDescending,
    bool? isGrid,
    String? searchTerm,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      orderBy: orderBy ?? this.orderBy,
      isDescending: isDescending ?? this.isDescending,
      isGrid: isGrid ?? this.isGrid,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }

  @override
  List<Object?> get props => [notes, orderBy, isDescending, isGrid, searchTerm];
}
