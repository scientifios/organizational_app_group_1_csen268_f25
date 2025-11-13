// lib/state/tasks_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../model/in_app_message.dart';
import '../model/task.dart';
import '../repository/messages_repository.dart';

class TasksState extends Equatable {
  final List<Task> tasks;
  final Map<String, String> lists;

  const TasksState({this.tasks = const [], this.lists = const {}});

  TasksState copyWith({List<Task>? tasks, Map<String, String>? lists}) =>
      TasksState(tasks: tasks ?? this.tasks, lists: lists ?? this.lists);

  @override
  List<Object?> get props => [tasks, lists];
}

class TasksCubit extends Cubit<TasksState> {
  TasksCubit({MessagesRepository? messagesRepository})
      : _messagesRepository = messagesRepository,
        super(const TasksState());

  final MessagesRepository? _messagesRepository;

  void seedDemoData() {
    final lists = {"l1": "School", "l2": "Work", "l3": "Personal"};
    final tasks = List.generate(
      8,
      (i) => Task(
        id: "t$i",
        title: "Task $i",
        important: i % 3 == 0,
        myDay: i % 2 == 0,
        listId: i % 2 == 0 ? "l1" : "l2",
      ),
    );
    emit(TasksState(tasks: tasks, lists: lists));
  }

  void addTask(String title, {String? listId, bool myDay = false}) {
    final t = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      listId: listId,
      myDay: myDay,
    );
    emit(state.copyWith(tasks: [...state.tasks, t]));
    _messagesRepository?.addMessage(
      title: 'Task added',
      body: '"$title" is now on your list.',
      category: MessageCategory.activity,
    );
  }

  void removeTask(String id) {
    final removed = state.tasks.firstWhere(
      (t) => t.id == id,
      orElse: () => const Task(id: '', title: ''),
    );
    emit(state.copyWith(tasks: state.tasks.where((t) => t.id != id).toList()));
    if (removed.id.isNotEmpty) {
      _messagesRepository?.addMessage(
        title: 'Task removed',
        body: '"${removed.title}" was deleted.',
        category: MessageCategory.activity,
      );
    }
  }

  void toggleComplete(String id) {
    Task? updated;
    final updatedTasks = state.tasks.map((t) {
      if (t.id == id) {
        final toggled = t.copyWith(completed: !t.completed);
        updated = toggled;
        return toggled;
      }
      return t;
    }).toList();
    emit(state.copyWith(tasks: updatedTasks));
    final target = updated;
    if (target != null) {
      if (target.completed) {
        _messagesRepository?.addMessage(
          title: 'Task completed',
          body: 'Nice work! "${target.title}" is done.',
          category: MessageCategory.reminder,
        );
      } else {
        _messagesRepository?.addMessage(
          title: 'Task reopened',
          body: '"${target.title}" is active again.',
          category: MessageCategory.tip,
        );
      }
    }
  }

  void toggleImportant(String id) {
    Task? updated;
    final updatedTasks = state.tasks.map((t) {
      if (t.id == id) {
        final toggled = t.copyWith(important: !t.important);
        updated = toggled;
        return toggled;
      }
      return t;
    }).toList();
    emit(state.copyWith(tasks: updatedTasks));
    final target = updated;
    if (target != null) {
      _messagesRepository?.addMessage(
        title: target.important ? 'Marked important' : 'Removed from important',
        body: '"${target.title}" ${target.important ? 'was pinned to Important.' : 'is no longer marked important.'}',
        category: MessageCategory.activity,
      );
    }
  }

  void addList(String name) {
    final id = "l${state.lists.length + 1}";
    final newLists = Map<String, String>.from(state.lists)..[id] = name;
    emit(state.copyWith(lists: newLists));
    _messagesRepository?.addMessage(
      title: 'List created',
      body: '"$name" is ready.',
      category: MessageCategory.tip,
    );
  }

  void addStep(String taskId, String step) {
    emit(state.copyWith(tasks: [
      for (final t in state.tasks)
        t.id == taskId ? t.copyWith(steps: [...t.steps, step]) : t
    ]));
  }

  void setNote(String taskId, String note) {
    emit(state.copyWith(tasks: [
      for (final t in state.tasks) t.id == taskId ? t.copyWith(note: note) : t
    ]));
  }
}
