import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_cubit.dart';
import '../../model/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool signup = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(signup ? 'Sign Up' : 'Login',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  const TextField(
                      decoration: InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 8),
                  const TextField(
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      context.read<AuthCubit>().login(
                            const User(
                              id: '121313',
                              email: 'ace@example.com',
                              nickname: 'Archie',
                              avatarUrl: '',
                              phoneNumber: '121313',
                            ),
                          );
                      context.go('/home');
                    },
                    child: Text(signup ? 'Create account' : 'Login'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => signup = !signup),
                    child: Text(signup
                        ? 'Have an account? Login'
                        : 'No account? Sign up'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
