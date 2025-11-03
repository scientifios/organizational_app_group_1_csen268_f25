import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../state/theme_cubit.dart';
import '../../state/auth_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeCubit>();
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: ()=> context.pop()), title: const Text('General Settings')),
      body: ListView(
        children: [
          const ListTile(leading: CircleAvatar(child: Icon(Icons.person)), title: Text('Ace Uni'), subtitle: Text('ace@example.com')),
          const Divider(height: 1),
          SwitchListTile(
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (_)=> theme.toggle(),
            title: const Text('Dark mode'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: (){
              context.read<AuthCubit>().logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
