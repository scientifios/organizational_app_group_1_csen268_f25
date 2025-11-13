import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PushTokenRepository {
  PushTokenRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _userTokens =>
      _firestore.collection('user_tokens');

  Future<void> saveToken({
    required String userId,
    required String token,
  }) async {
    final platform = defaultTargetPlatform.name;
    await _userTokens.doc(userId).collection('tokens').doc(token).set({
      'token': token,
      'platform': platform,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteToken({
    required String userId,
    required String token,
  }) async {
    final doc = _userTokens.doc(userId).collection('tokens').doc(token);
    final snapshot = await doc.get();
    if (snapshot.exists) {
      await doc.delete();
    }
  }
}
