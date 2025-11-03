import 'package:bloc/bloc.dart';

sealed class AuthState {}
class AuthUnknown extends AuthState {}
class Authenticated extends AuthState {}
class Unauthenticated extends AuthState {}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthUnknown());

  void login() => emit(Authenticated());
  void logout() => emit(Unauthenticated());
}
