// lib/ui/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../state/tasks_cubit.dart';
import '../widgets/prompt_dialog.dart';
import '../../state/auth_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const double hPad = 16;
    const double trailingW = 40;
    final lists = context.select((TasksCubit c) => c.state.lists);
    final user = context.select((AuthCubit c) {
      final state = c.state;
      return state is Authenticated ? state.user : null;
    });
    final avatarUrl = user?.avatarUrl ?? '';
    final initials = (user?.nickname ?? user?.email ?? '').trim().isNotEmpty
        ? (user!.nickname ?? user.email).trim()[0].toUpperCase()
        : 'U';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 22,
              backgroundImage:
                  avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(avatarUrl.isEmpty ? 0.15 : 1),
              child: avatarUrl.isEmpty
                  ? Text(
                      initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
            tooltip: 'Profile & Settings',
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(hPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello!', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text('Quick access to your tasks and messages',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[600])),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _QuickFullRow(
                          icon: Icons.wb_sunny_outlined,
                          label: 'My Day',
                          onTap: () => context.push('/tasks/myday'),
                        ),
                        const SizedBox(height: 12),
                        _QuickFullRow(
                          icon: Icons.star_border,
                          label: 'Important',
                          onTap: () => context.push('/tasks/important'),
                        ),
                        const SizedBox(height: 12),
                        _QuickFullRow(
                          icon: Icons.task_alt,
                          label: 'Tasks',
                          onTap: () => context.push('/tasks'),
                        ),
                        const SizedBox(height: 12),
                        _QuickFullRow(
                          icon: Icons.notifications_outlined,
                          label: 'Messages',
                          onTap: () => context.push('/notifications'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text('Lists',
                              style: Theme.of(context).textTheme.titleLarge),
                          trailing: SizedBox(
                            width: trailingW,
                            height: trailingW,
                            child: Center(
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.add),
                                tooltip: 'New List',
                                onPressed: () async {
                                  final name =
                                      await promptDialog(context, 'New list name');
                                  if (name != null && context.mounted) {
                                    await context.read<TasksCubit>().addList(name);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: lists.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Text('No lists'),
                                  ),
                                )
                              : Column(
                                  children: [
                                    for (final entry in lists.entries)
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(Icons.list_outlined),
                                        title: Text(entry.value),
                                        trailing: const SizedBox(
                                          width: trailingW,
                                          child:
                                              Center(child: Icon(Icons.chevron_right)),
                                        ),
                                        onTap: () =>
                                            context.push('/tasks/list/${entry.key}'),
                                      ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickFullRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickFullRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
