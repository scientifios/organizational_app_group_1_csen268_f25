import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../model/in_app_message.dart';
import '../repository/push_token_repository.dart';
import '../state/auth_cubit.dart';
import '../state/messages_cubit.dart';

class PushNotificationService {
  PushNotificationService({
    FirebaseMessaging? messaging,
    required PushTokenRepository tokenRepository,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _tokenRepository = tokenRepository;

  final FirebaseMessaging _messaging;
  final PushTokenRepository _tokenRepository;
  MessagesCubit? _messagesCubit;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<AuthState>? _authSub;
  bool _initialized = false;
  String? _currentUserId;
  String? _lastToken;

  Future<void> ensureInitialized({
    required AuthCubit authCubit,
    required MessagesCubit messagesCubit,
  }) async {
    if (_initialized) return;
    _initialized = true;
    _messagesCubit = messagesCubit;

    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );
    }

    await _messaging.setAutoInitEnabled(true);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedApp);

    _authSub = authCubit.stream.listen(_handleAuthState);
    _handleAuthState(authCubit.state);
  }

  void _handleAuthState(AuthState state) {
    if (state is Authenticated) {
      _currentUserId = state.user.id;
      _syncToken();
    } else {
      _deleteExistingToken();
      _currentUserId = null;
    }
  }

  Future<void> _syncToken() async {
    final userId = _currentUserId;
    if (userId == null) return;
    final token = await _messaging.getToken();
    if (token == null) return;
    _lastToken = token;
    debugPrint('FCM token: $token');
    await _tokenRepository.saveToken(userId: userId, token: token);
    _tokenRefreshSub ??=
        _messaging.onTokenRefresh.listen((newToken) async {
      final uid = _currentUserId;
      if (uid == null) return;
      _lastToken = newToken;
      await _tokenRepository.saveToken(userId: uid, token: newToken);
    });
  }

  Future<void> _deleteExistingToken() async {
    final userId = _currentUserId;
    final token = _lastToken;
    if (userId != null && token != null) {
      await _tokenRepository.deleteToken(userId: userId, token: token);
    }
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
    _lastToken = null;
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final messagesCubit = _messagesCubit;
    if (messagesCubit == null) {
      return;
    }

    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] ?? 'Update';
    final body =
        notification?.body ?? message.data['body'] ?? 'You have a new message.';
    messagesCubit.addInfo(
      title: title,
      body: body,
      category: MessageCategory.reminder,
    );
  }

  void _handleOpenedApp(RemoteMessage message) {
    _handleForegroundMessage(message);
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _authSub?.cancel();
  }
}
