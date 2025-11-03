// lib/model/task.dart
import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final bool completed;
  final bool important;
  final bool myDay;
  final String? listId;
  final List<String> steps;
  final String? note;

  const Task({
    required this.id,
    required this.title,
    this.completed = false,
    this.important = false,
    this.myDay = false,
    this.listId,
    this.steps = const [],
    this.note,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? completed,
    bool? important,
    bool? myDay,
    String? listId,
    List<String>? steps,
    String? note,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      important: important ?? this.important,
      myDay: myDay ?? this.myDay,
      listId: listId ?? this.listId,
      steps: steps ?? this.steps,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, title, completed, important, myDay, listId, steps, note];
}
