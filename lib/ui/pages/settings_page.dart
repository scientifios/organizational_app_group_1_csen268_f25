import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../state/theme_cubit.dart';
import '../../state/auth_cubit.dart';
import '../../model/user.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final themeMode = context.watch<ThemeCubit>().state;
    final isDarkMode = themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('General Settings'),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state is Authenticated ? state.user : null;
          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              const SizedBox(height: 8),
              const _SectionHeader('Personal Information'),
              _SettingsTile(
                title: 'User ID',
                value: user?.id ?? 'Add nickname',
                onTap: ()async{
                  final newId = await _editTextDialog(
                    context,
                    title: 'Edit User ID',
                    initial: user?.id ?? '',
                    hint: 'Enter new User ID',
                  );
                  if(newId != null){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User ID -> $newId (demo only)'))
                      );
                  }
                },
              ),
              const Divider(height: 0),
              _SettingsTile(
                title: 'Avatar',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AvatarPreview(user: user),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
                onTap: () async{
                  final source = await _chooseAvatarSourceDialog(context);
                  if (source != null){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Avatar: $source (demo only)'))
                      );
                  }
                },
              ),
              const Divider(height: 0),
              _SettingsTile(
                title: 'Nickname',
                value: user?.nickname ?? 'Add nickname',
                onTap: () async{
                  final text = await _editTextDialog(
                    context, 
                    title: 'Enter Nickname',
                    initial: user?.nickname ?? '',
                    hint: 'Enter nickname',
                  );
                  if (text != null){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Avatar: $text (demo only)'))
                      );
                  }                  
                }
              ),
              const SizedBox(height: 16),
              const _SectionHeader('Account Setting'),
              _SettingsTile(
                title: 'Mobile Phone',
                value: user?.phoneNumber ?? 'Add phone',
                onTap: () => _showWorkInProgress(context, 'Mobile Phone'),
              ),
              const Divider(height: 0),
              _SettingsTile(
                title: 'Change Password',
                onTap: () => _showWorkInProgress(context, 'Change Password'),
              ),
              // const Divider(height: 0),
              // _SettingsTile(
              //   title: 'Nickname',
              //   value: user?.nickname ?? 'Add nickname',
              //   onTap: () => _showWorkInProgress(context, 'Nickname'),
              // ),
              const Divider(height: 0),
              _SettingsTile(
                title: 'Cancel User',
                onTap: () => _showWorkInProgress(context, 'Cancel User'),
              ),
              const SizedBox(height: 16),
              const _SectionHeader('Authority Setting'),
              _SettingsTile(
                title: 'Service Items',
                onTap: () => _showWorkInProgress(context, 'Service Items'),
              ),
              const Divider(height: 0),
              _SettingsTile(
                title: 'Privacy Policy',
                onTap: () => _showWorkInProgress(context, 'Privacy Policy'),
              ),
              const Divider(height: 0),
              _SettingsTile(
                title: 'Dark Mode',
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (_) => themeCubit.toggle(),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () {
                      context.read<AuthCubit>().logout();
                      context.go('/login');
                    },
                    child: const Text('Logout'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.value,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final defaultTrailingChildren = <Widget>[];
    if (value != null) {
      defaultTrailingChildren.add(
        Text(
          value!,
          style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      );
    }
    if (onTap != null) {
      if (defaultTrailingChildren.isNotEmpty) {
        defaultTrailingChildren.add(const SizedBox(width: 6));
      }
      defaultTrailingChildren.add(const Icon(Icons.chevron_right, size: 20));
    }

    return ListTile(
      title: Text(title),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      trailing: trailing ??
          (defaultTrailingChildren.isEmpty
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: defaultTrailingChildren)),
      onTap: onTap,
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user?.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(avatarUrl),
      );
    }

    final nickname = user?.nickname ?? '';
    final hasInitial = nickname.isNotEmpty;
    return CircleAvatar(
      radius: 18,
      child: hasInitial
          ? Text(nickname.substring(0, 1).toUpperCase())
          : const Icon(Icons.person, size: 18),
    );
  }
}

void _showWorkInProgress(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('「$feature」is coming soon')),
  );
}

Future<String?> _editTextDialog(
  BuildContext context, {
  required String title,
  String initial = '',
  String? hint,
  TextInputType? keyboardType,
}) async {
  final controller = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    ),
  );

  if (result == null || result.isEmpty || result == initial) return null;
  return result;
}

Future<String?> _chooseAvatarSourceDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => SimpleDialog(
      title: const Text('Change Avatar'),
      children: [
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, 'Take Photo'),
          child: const ListTile(
            leading: Icon(Icons.photo_camera),
            title: Text('Take Photo'),
          ),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, 'Choose from Gallery'),
          child: const ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Choose from Gallery'),
          ),
        ),
        const Divider(height: 0),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context),
          child: const Center(child: Text('Cancel')),
        ),
      ],
    ),
  );
}
