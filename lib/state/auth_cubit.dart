import 'package:bloc/bloc.dart';

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
  AuthCubit() : super(const AuthUnknown());

  void login(User user) => emit(Authenticated(user));
  void logout() => emit(const Unauthenticated());
}
