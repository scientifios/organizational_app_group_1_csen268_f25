import 'package:bloc/bloc.dart';
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
}
