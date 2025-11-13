import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../model/user.dart';

sealed class AuthState {
  const AuthState();
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class Authenticated extends AuthState {
  const Authenticated(this.user);

  final User user;
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({fb_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
        super(const AuthUnknown()) {
    _subscription = _firebaseAuth.authStateChanges().listen(_onUserChanged);
  }

  final fb_auth.FirebaseAuth _firebaseAuth;
  StreamSubscription<fb_auth.User?>? _subscription;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Unable to log in.');
    }
  }

  Future<void> signup({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Unable to create account.');
    }
  }

  Future<void> logout() {
    return _firebaseAuth.signOut();
  }

  void _onUserChanged(fb_auth.User? firebaseUser) {
    if (firebaseUser == null) {
      emit(const Unauthenticated());
      return;
    }

    emit(Authenticated(_mapFirebaseUser(firebaseUser)));
  }

  User _mapFirebaseUser(fb_auth.User firebaseUser) {
    final email = firebaseUser.email ?? '';
    final nickname = firebaseUser.displayName?.trim();
    final fallbackNickname =
        email.isNotEmpty ? email.split('@').first : 'User';

    return User(
      id: firebaseUser.uid,
      email: email,
      nickname:
          nickname != null && nickname.isNotEmpty ? nickname : fallbackNickname,
      avatarUrl: firebaseUser.photoURL ?? '',
      phoneNumber: firebaseUser.phoneNumber ?? '',
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => 'AuthFailure: $message';
}
