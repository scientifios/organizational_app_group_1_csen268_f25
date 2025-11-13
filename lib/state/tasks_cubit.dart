// lib/state/tasks_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../model/task.dart';  //

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
  TasksCubit() : super(const TasksState());

  void seedDemoData() {
    final lists = {"l1": "School", "l2": "Work", "l3": "Personal"};
    final tasks = List.generate(8, (i) => Task(
      id: "t$i",
      title: "Task $i",
      important: i % 3 == 0,
      myDay: i % 2 == 0,
      listId: i % 2 == 0 ? "l1" : "l2",
      audioClips: const [],
    ));
    emit(TasksState(tasks: tasks, lists: lists));
  }

  void addTask(String title, {String? listId, bool myDay = false}) {
    final t = Task(id: DateTime.now().millisecondsSinceEpoch.toString(), title: title, listId: listId, myDay: myDay);
    emit(state.copyWith(tasks: [...state.tasks, t]));
  }

  void removeTask(String id) {
    emit(state.copyWith(tasks: state.tasks.where((t) => t.id != id).toList()));
  }

  void toggleComplete(String id) {
    emit(state.copyWith(tasks: [
      for (final t in state.tasks) t.id == id ? t.copyWith(completed: !t.completed) : t
    ]));
  }

  void toggleImportant(String id) {
    emit(state.copyWith(tasks: [
      for (final t in state.tasks) t.id == id ? t.copyWith(important: !t.important) : t
    ]));
  }

  void addList(String name) {
    final id = "l${state.lists.length + 1}";
    final newLists = Map<String, String>.from(state.lists)..[id] = name;
    emit(state.copyWith(lists: newLists));
  }

  void addStep(String taskId, String step) {
    emit(state.copyWith(tasks: [
      for (final t in state.tasks) t.id == taskId ? t.copyWith(steps: [...t.steps, step]) : t
    ]));
  }

  void setNote(String taskId, String note) {
    emit(state.copyWith(tasks: [
      for (final t in state.tasks) t.id == taskId ? t.copyWith(note: note) : t
    ]));
  }

  void addAudioClip(String taskId, String path) {
    emit(state.copyWith(tasks: [
      for (final t in state.tasks)
        if (t.id == taskId)
          t.copyWith(audioClips: [...t.audioClips, path])
        else
          t
    ]));
  }

  void removeAudioClip(String taskId, String path) {
    emit(state.copyWith(tasks: [
      for (final t in state.tasks)
        if (t.id == taskId)
          t.copyWith(audioClips: t.audioClips.where((clip) => clip != path).toList())
        else
          t
    ]));
  }
}
