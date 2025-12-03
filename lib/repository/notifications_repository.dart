import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsRepository {
  NotificationsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _userNotifications(String userId) =>
      _firestore.collection('notifications').doc(userId).collection('messages');

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String route = '/notifications',
    String? taskId,
  }) {
    return _userNotifications(userId).add({
      'title': title,
      'body': body,
      'route': route,
      'taskId': taskId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
