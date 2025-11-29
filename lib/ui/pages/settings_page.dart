import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:organizational_app_group_1_csen268_f25/ui/pages/service_items_page.dart';
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
                  if (source == null) return;

                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: source,
                    maxWidth: 1024,
                    maxHeight: 1024,
                  );
                  if (picked == null) return;

                  await context.read<AuthCubit>().updateAvatar(File(picked.path));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Avatar updated')),
                  );
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
                    await context.read<AuthCubit>().updateNickname(text);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nickname updated')),
                    );
                  }                  
                }
              ),
              const SizedBox(height: 16),
              const _SectionHeader('Account Setting'),
              _SettingsTile(
                title: 'Mobile Phone',
                value: (user?.phoneNumber ?? '').isNotEmpty
                    ? user!.phoneNumber
                    : '',
                onTap: () async{
                  final phone = await _editTextDialog(
                    context, 
                    title: 'Edit Mobile Phone',
                    initial: user?.phoneNumber ?? '',
                    hint: 'Enter phone number',
                    keyboardType: TextInputType.phone,
                  );
                  if (phone != null){
                    await context.read<AuthCubit>().updatePhone(phone);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Phone updated')),
                    );
                  }
                }
              ),
              const Divider(height: 0),
              _SettingsTile(
                title: 'Change Password',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                  );
                },
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
                onTap: () => _handleCancelUser(context),
              ),
              const SizedBox(height: 16),
              const _SectionHeader('Authority Setting'),
              _SettingsTile(
                title: 'Service Items',
                onTap: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const ServiceItemsPage())
                  );
                }
              ),
              const Divider(height: 0),
              _SettingsTile(
                title: 'Privacy Policy',
                onTap: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const ServiceItemsPage())
                  );
                }
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
                    onPressed: () async {
                      await context.read<AuthCubit>().logout();
                      if (!context.mounted) return;
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

Future<ImageSource?> _chooseAvatarSourceDialog(BuildContext context) {
  return showDialog<ImageSource>(
    context: context,
    builder: (_) => SimpleDialog(
      title: const Text('Change Avatar'),
      children: [
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, ImageSource.camera),
          child: const ListTile(
            leading: Icon(Icons.photo_camera),
            title: Text('Take Photo'),
          ),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, ImageSource.gallery),
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

Future<void> _handleCancelUser(BuildContext context) async {
  final success = await _showCancelUserDialog(context);
  if (success == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User cancelled successfully.')),
    );
    context.go('/login');
  }
}

Future<bool?> _showCancelUserDialog(BuildContext parentContext) {
  return showDialog<bool>(
    context: parentContext,
    barrierDismissible: false,
    builder: (_) => _CancelUserDialog(parentContext: parentContext),
  );
}

class _CancelUserDialog extends StatefulWidget {
  const _CancelUserDialog({required this.parentContext});

  final BuildContext parentContext;

  @override
  State<_CancelUserDialog> createState() => _CancelUserDialogState();
}

class _CancelUserDialogState extends State<_CancelUserDialog> {
  final _controller = TextEditingController();
  String? _errorText;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _controller.text.trim();
    if (password.isEmpty) {
      setState(() => _errorText = 'Password is required.');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await widget.parentContext
          .read<AuthCubit>()
          .deleteAccount(password: password);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Failed to cancel user.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancel User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This action is irreversible. Do you want to cancel this user?',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm Password'),
            autofocus: true,
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
        FilledButton.tonal(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Cancel User'),
        ),
      ],
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final messenger = ScaffoldMessenger.of(context);
    final current = _oldCtrl.text.trim();
    final newPassword = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (current.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (newPassword.length < 6) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters long.'),
        ),
      );
      return;
    }

    if (newPassword != confirm) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('New password and confirmation do not match.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    try {
      await context.read<AuthCubit>().changePassword(
            currentPassword: current,
            newPassword: newPassword,
          );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
      Navigator.of(context).pop();
    } on AuthFailure catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to change password.')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _oldCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Old Password'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (!_submitting) {
                  _handleSubmit();
                }
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _handleSubmit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
