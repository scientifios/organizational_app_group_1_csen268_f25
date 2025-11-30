import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/task.dart';

class TasksRepository {
  TasksRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _tasksRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('tasks');

  CollectionReference<Map<String, dynamic>> _listsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('lists');

  Stream<List<Task>> watchTasks(String userId) {
    return _tasksRef(userId).snapshots().map(
          (snapshot) =>
              snapshot.docs.map(_taskFromDoc).toList(growable: false),
        );
  }

  Stream<Map<String, String>> watchLists(String userId) {
    return _listsRef(userId).snapshots().map((snapshot) {
      final entries = <String, String>{};
      for (final doc in snapshot.docs) {
        final name = (doc.data()['name'] as String?)?.trim();
        if (name != null && name.isNotEmpty) {
          entries[doc.id] = name;
        }
      }
      return entries;
    });
  }

  Future<void> createTask({
    required String userId,
    required String title,
    String? listId,
    bool myDay = false,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    int? estimateMinutes,
    int notifyBeforeDays = 1,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    final doc = _tasksRef(userId).doc();
    await doc.set({
      'title': trimmed,
      'completed': false,
      'important': false,
      'myDay': myDay,
      'listId': listId,
      'steps': <String>[],
      'note': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'priority': priority.name,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'estimateMinutes': estimateMinutes,
      'notifyBeforeDays': notifyBeforeDays,
    });
  }

  Future<void> updateTask(String userId, Task task) async {
    final payload = {
      'title': task.title,
      'completed': task.completed,
      'important': task.important,
      'myDay': task.myDay,
      'listId': task.listId,
      'steps': task.steps,
      'note': task.note,
      'updatedAt': FieldValue.serverTimestamp(),
      'priority': task.priority.name,
      'dueDate':
          task.dueDate != null ? Timestamp.fromDate(task.dueDate!) : null,
      'estimateMinutes': task.estimateMinutes,
      'notifyBeforeDays': task.notifyBeforeDays,
    };

    await _tasksRef(userId).doc(task.id).update(payload);
  }

  Future<void> deleteTask(String userId, String taskId) {
    return _tasksRef(userId).doc(taskId).delete();
  }

  Future<void> createList({
    required String userId,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _listsRef(userId).add({
      'name': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Task _taskFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final rawPriority = data['priority'];
    final priority = rawPriority is String
        ? TaskPriorityX.fromString(rawPriority)
        : TaskPriority.medium;

    return Task(
      id: doc.id,
      title: data['title'] as String? ?? '',
      completed: data['completed'] as bool? ?? false,
      important: data['important'] as bool? ?? false,
      myDay: data['myDay'] as bool? ?? false,
      listId: data['listId'] as String?,
      steps: _mapSteps(data['steps']),
      note: data['note'] as String?,
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
      priority: priority,
      dueDate: _toDateTime(data['dueDate']),
      estimateMinutes: (data['estimateMinutes'] as num?)?.toInt(),
      notifyBeforeDays: (data['notifyBeforeDays'] as num?)?.toInt() ?? 1,
    );
  }

  List<String> _mapSteps(dynamic raw) {
    if (raw is Iterable) {
      return raw.whereType<String>().toList(growable: false);
    }
    return const [];
  }

  DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
