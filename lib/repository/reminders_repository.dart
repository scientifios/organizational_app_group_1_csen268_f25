import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/task.dart';

class RemindersRepository {
  RemindersRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _remindersRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('reminders');

  Future<void> syncReminder({
    required String userId,
    required Task task,
  }) async {
    final doc = _remindersRef(userId).doc(task.id);
    final shouldSchedule = task.dueDate != null &&
        !task.completed &&
        task.notifyBeforeDays != 0;

    if (!shouldSchedule) {
      try {
        await doc.delete();
      } catch (_) {
        // ignore if doc doesn't exist
      }
      return;
    }

    final dueDate = task.dueDate!;
    final computed = _computeSchedule(task.notifyBeforeDays, dueDate);

    await doc.set({
      'taskId': task.id,
      'title': task.title,
      'userId': userId,
      'dueDate': Timestamp.fromDate(dueDate),
      'notifyAt': Timestamp.fromDate(computed.notifyAt),
      'notifyBeforeDays': task.notifyBeforeDays,
      'repeatIntervalMinutes': computed.repeatIntervalMinutes,
      'listId': task.listId,
      'sent': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  _Schedule _computeSchedule(int notifyBeforeDays, DateTime dueDate) {
    if (notifyBeforeDays == -3) {
      // Repeat every 5 minutes starting ~now until due time.
      return _Schedule(
        notifyAt: DateTime.now().add(const Duration(minutes: 1)),
        repeatIntervalMinutes: 5,
      );
    }
    if (notifyBeforeDays == -2) {
      return _Schedule(
        notifyAt: DateTime.now().add(const Duration(minutes: 5)),
      );
    }
    if (notifyBeforeDays < 0) {
      return _Schedule(notifyAt: dueDate);
    }
    return _Schedule(
      notifyAt: dueDate.subtract(Duration(days: notifyBeforeDays)),
    );
  }
}

class _Schedule {
  _Schedule({required this.notifyAt, this.repeatIntervalMinutes});

  final DateTime notifyAt;
  final int? repeatIntervalMinutes;
}
