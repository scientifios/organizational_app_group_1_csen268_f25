// lib/model/task.dart
import 'package:equatable/equatable.dart';

enum TaskPriority { high, medium, low }

extension TaskPriorityX on TaskPriority {
  static TaskPriority fromString(String? raw) {
    switch (raw) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }

  String get label {
    switch (this) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  int get weight {
    switch (this) {
      case TaskPriority.high:
        return 0;
      case TaskPriority.medium:
        return 1;
      case TaskPriority.low:
        return 2;
    }
  }
}

class Task extends Equatable {
  final String id;
  final String title;
  final bool completed;
  final bool important;
  final bool myDay;
  final String? listId;
  final List<String> steps;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final TaskPriority priority;
  final DateTime? dueDate;
  final int? estimateMinutes;
  final int notifyBeforeDays;

  const Task({
    required this.id,
    required this.title,
    this.completed = false,
    this.important = false,
    this.myDay = false,
    this.listId,
    this.steps = const [],
    this.note,
    this.createdAt,
    this.updatedAt,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.estimateMinutes,
    this.notifyBeforeDays = 1,
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
    DateTime? createdAt,
    DateTime? updatedAt,
    TaskPriority? priority,
    DateTime? dueDate,
    int? estimateMinutes,
    int? notifyBeforeDays,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      estimateMinutes: estimateMinutes ?? this.estimateMinutes,
      notifyBeforeDays: notifyBeforeDays ?? this.notifyBeforeDays,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        completed,
        important,
        myDay,
        listId,
        steps,
        note,
        createdAt,
        updatedAt,
        priority,
        dueDate,
        estimateMinutes,
        notifyBeforeDays,
      ];
}
