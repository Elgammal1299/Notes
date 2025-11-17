import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  Note({
    required this.title,
    required this.content,
    required this.contentJson,
    required this.dateCreated,
    required this.dateModified,
    required this.tags,
  });

  @HiveField(0)
  String? title;

  @HiveField(1)
  String? content;

  @HiveField(2)
  String contentJson;

  @HiveField(3)
  int dateCreated;

  @HiveField(4)
  int dateModified;

  @HiveField(5)
  List<String>? tags;

  @HiveField(6)
  int? reminderDateTime;

  // Create a copy with modified fields
  Note copyWith({
    String? title,
    String? content,
    String? contentJson,
    int? dateCreated,
    int? dateModified,
    List<String>? tags,
    int? reminderDateTime,
  }) {
    return Note(
      title: title ?? this.title,
      content: content ?? this.content,
      contentJson: contentJson ?? this.contentJson,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      tags: tags ?? this.tags,
    )..reminderDateTime = reminderDateTime ?? this.reminderDateTime;
  }
}
