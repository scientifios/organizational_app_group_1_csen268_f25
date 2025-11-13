// lib/state/tasks_cubit.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../model/in_app_message.dart';
import '../model/task.dart';
import '../repository/messages_repository.dart';
import '../repository/tasks_repository.dart';
import 'auth_cubit.dart';

class TasksState extends Equatable {
  final List<Task> tasks;
  final Map<String, String> lists;

  const TasksState({
    this.tasks = const [],
    this.lists = const {},
  });

  TasksState copyWith({
    List<Task>? tasks,
    Map<String, String>? lists,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      lists: lists ?? this.lists,
    );
  }

  @override
  List<Object?> get props => [tasks, lists];
}

class TasksCubit extends Cubit<TasksState> {
  TasksCubit({
    required TasksRepository tasksRepository,
    MessagesRepository? messagesRepository,
    required AuthCubit authCubit,
  })  : _tasksRepository = tasksRepository,
        _messagesRepository = messagesRepository,
        super(const TasksState()) {
    _authSubscription = authCubit.stream.listen(_handleAuthState);
    _handleAuthState(authCubit.state);
  }

  final TasksRepository _tasksRepository;
  final MessagesRepository? _messagesRepository;

  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<List<Task>>? _tasksSubscription;
  StreamSubscription<Map<String, String>>? _listsSubscription;

  String? _userId;

  void _handleAuthState(AuthState authState) {
    final user = authState is Authenticated ? authState.user : null;
    if (user == null) {
      _userId = null;
      _detachStreams();
      emit(const TasksState());
      return;
    }

    if (_userId == user.id && _tasksSubscription != null) {
      return;
    }

    _userId = user.id;
    _startStreams();
  }

  void _startStreams() {
    final userId = _userId;
    if (userId == null) return;

    _detachStreams();

    _tasksSubscription =
        _tasksRepository.watchTasks(userId).listen((tasks) {
      emit(state.copyWith(tasks: tasks));
    });

    _listsSubscription =
        _tasksRepository.watchLists(userId).listen((lists) {
      emit(state.copyWith(lists: lists));
    });
  }

  void _detachStreams() {
    _tasksSubscription?.cancel();
    _tasksSubscription = null;
    _listsSubscription?.cancel();
    _listsSubscription = null;
  }

  Future<void> addTask(String title, {String? listId, bool myDay = false}) async {
    final userId = _userId;
    if (userId == null) return;
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    await _tasksRepository.createTask(
      userId: userId,
      title: trimmed,
      listId: listId,
      myDay: myDay,
    );

    _messagesRepository?.addMessage(
      title: 'Task added',
      body: '"$trimmed" is now on your list.',
      category: MessageCategory.activity,
    );
  }

  Future<void> removeTask(String id) async {
    final userId = _userId;
    if (userId == null) return;
    final removed = _taskById(id);
    await _tasksRepository.deleteTask(userId, id);
    if (removed != null) {
      _messagesRepository?.addMessage(
        title: 'Task removed',
        body: '"${removed.title}" was deleted.',
        category: MessageCategory.activity,
      );
    }
  }

  Future<void> toggleComplete(String id) async {
    final userId = _userId;
    if (userId == null) return;
    final task = _taskById(id);
    if (task == null) return;

    final updated = task.copyWith(completed: !task.completed);
    await _tasksRepository.updateTask(userId, updated);

    if (updated.completed) {
      _messagesRepository?.addMessage(
        title: 'Task completed',
        body: 'Nice work! "${updated.title}" is done.',
        category: MessageCategory.reminder,
      );
    } else {
      _messagesRepository?.addMessage(
        title: 'Task reopened',
        body: '"${updated.title}" is active again.',
        category: MessageCategory.tip,
      );
    }
  }

  Future<void> toggleImportant(String id) async {
    final userId = _userId;
    if (userId == null) return;
    final task = _taskById(id);
    if (task == null) return;

    final updated = task.copyWith(important: !task.important);
    await _tasksRepository.updateTask(userId, updated);

    _messagesRepository?.addMessage(
      title: updated.important ? 'Marked important' : 'Removed from important',
      body: '"${updated.title}" ${updated.important ? 'was pinned to Important.' : 'is no longer marked important.'}',
      category: MessageCategory.activity,
    );
  }

  Future<void> addList(String name) async {
    final userId = _userId;
    if (userId == null) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    await _tasksRepository.createList(userId: userId, name: trimmed);

    _messagesRepository?.addMessage(
      title: 'List created',
      body: '"$trimmed" is ready.',
      category: MessageCategory.tip,
    );
  }

  Future<void> addStep(String taskId, String step) async {
    final userId = _userId;
    if (userId == null) return;
    final trimmed = step.trim();
    if (trimmed.isEmpty) return;
    final task = _taskById(taskId);
    if (task == null) return;

    final updated =
        task.copyWith(steps: [...task.steps, trimmed]);
    await _tasksRepository.updateTask(userId, updated);
  }

  Future<void> setNote(String taskId, String note) async {
    final userId = _userId;
    if (userId == null) return;
    final task = _taskById(taskId);
    if (task == null) return;

    final trimmed = note.trim();
    final updated = task.copyWith(note: trimmed.isEmpty ? null : trimmed);
    await _tasksRepository.updateTask(userId, updated);
  }

  Task? _taskById(String id) {
    try {
      return state.tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> close() async {
    await _tasksSubscription?.cancel();
    await _listsSubscription?.cancel();
    await _authSubscription?.cancel();
    return super.close();
  }
}
