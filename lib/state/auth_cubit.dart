import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../model/user.dart';
import '../services/profile_repository.dart';

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
  AuthCubit({
    fb_auth.FirebaseAuth? firebaseAuth,
    ProfileRepository? profileRepository,
  })  : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
        _profileRepo = profileRepository ?? ProfileRepository(),
        super(const AuthUnknown()) {
    _subscription = _firebaseAuth.authStateChanges().listen(_onUserChanged);
  }

  final fb_auth.FirebaseAuth _firebaseAuth;
  final ProfileRepository _profileRepo;
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
      // Emit authenticated state immediately so router guards see it without a second tap.
      await _onUserChanged(_firebaseAuth.currentUser);
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

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw const AuthFailure('No authenticated user.');
    }

    final credential = fb_auth.EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Unable to change password.');
    }
  }

  Future<void> deleteAccount({required String password}) async {
    final user = _firebaseAuth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw const AuthFailure('No authenticated user.');
    }

    final credential = fb_auth.EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      await user.delete();
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Unable to delete the account.');
    }
  }

  Future<void> _onUserChanged(fb_auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      emit(const Unauthenticated());
      return;
    }

    try {
      final profile = await _profileRepo.fetch(
        firebaseUser.uid,
        email: firebaseUser.email,
      );
      emit(Authenticated(profile));
    } catch (_) {
      emit(Authenticated(_mapFirebaseUser(firebaseUser)));
    }
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

  Future<void> updateNickname(String nickname) async {
    final current = state;
    if (current is! Authenticated) return;
    final updated = current.user.copyWith(nickname: nickname);
    await _profileRepo.save(updated);
    emit(Authenticated(updated));
  }

  Future<void> updatePhone(String phoneNumber) async {
    final current = state;
    if (current is! Authenticated) return;
    final updated = current.user.copyWith(phoneNumber: phoneNumber);
    await _profileRepo.save(updated);
    emit(Authenticated(updated));
  }

  Future<void> updateAvatar(File file) async {
    final current = state;
    if (current is! Authenticated) return;
    final avatarUrl = await _profileRepo.uploadAvatar(current.user.id, file);
    final updated = current.user.copyWith(avatarUrl: avatarUrl);
    await _profileRepo.save(updated);
    emit(Authenticated(updated));
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
