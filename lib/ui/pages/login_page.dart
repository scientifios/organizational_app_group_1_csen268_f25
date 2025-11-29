import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _signup = false;
  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _signup ? 'Sign Up' : 'Login',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: ValueKey('email_field_${_signup ? 'signup' : 'login'}'),
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      autofillHints: const [AutofillHints.username],
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      validator: (text) {
                        final value = text?.trim() ?? '';
                        if (value.isEmpty) return 'Please enter your email.';
                        if (!value.contains('@')) return 'Email looks invalid.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: ValueKey('password_field_${_signup ? 'signup' : 'login'}'),
                      controller: _passwordCtrl,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          tooltip:
                              _obscurePassword ? 'Show password' : 'Hide password',
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      autofillHints: const [AutofillHints.password],
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (text) {
                        final value = text ?? '';
                        if (value.isEmpty) return 'Please enter your password.';
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_signup ? 'Create account' : 'Login'),
                      ),
                    ),
                    TextButton(
                      onPressed: _submitting ? null : () => _switchMode(!_signup),
                      child: Text(
                        _signup
                            ? 'Have an account? Login'
                            : 'No account? Sign up',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final auth = context.read<AuthCubit>();
    try {
      if (_signup) {
        await auth.signup(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );
        await auth.logout();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created. Please log in.'),
          ),
        );
        _clearFormAndSetMode(signupMode: false);
        context.go('/login');
        return;
      } else {
        await auth.login(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );
      }
      if (!mounted) return;
      context.go('/home');
    } on AuthFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _switchMode(bool signupMode) {
    _clearFormAndSetMode(signupMode: signupMode);
  }

  void _clearFormAndSetMode({required bool signupMode}) {
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _signup = signupMode;
      _resetFormFields();
      _formKey.currentState?.reset();
    });
  }

  void _resetFormFields() {
    _emailCtrl.clear();
    _passwordCtrl.clear();
  }
}
