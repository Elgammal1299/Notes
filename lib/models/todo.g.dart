// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 1;

  @override
  Todo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Todo(
      title: fields[0] as String,
      description: fields[1] as String?,
      isCompleted: fields[2] as bool,
      dateCreated: fields[3] as int,
      dueDate: fields[4] as int?,
      priority: fields[5] as int,
      category: fields[6] as int,
      subtasks: (fields[7] as List?)?.cast<String>(),
      subtasksCompleted: (fields[8] as List?)?.cast<bool>(),
      reminderDateTime: fields[9] as int?,
      isRecurring: fields[10] as bool,
      recurringPattern: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.dateCreated)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.subtasks)
      ..writeByte(8)
      ..write(obj.subtasksCompleted)
      ..writeByte(9)
      ..write(obj.reminderDateTime)
      ..writeByte(10)
      ..write(obj.isRecurring)
      ..writeByte(11)
      ..write(obj.recurringPattern);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
