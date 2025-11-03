import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../state/tasks_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final lists = context.select((TasksCubit c) => c.state.lists);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Home', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _QuickCard(icon: Icons.wb_sunny_outlined, label: 'My Day', onTap: () => context.push('/tasks/myday')),
          _QuickCard(icon: Icons.star_border, label: 'Important', onTap: () => context.push('/tasks/important')),
          _QuickCard(icon: Icons.task_alt, label: 'Tasks', onTap: () => context.push('/tasks')),
          _QuickCard(icon: Icons.notifications_outlined, label: 'Notification', onTap: () => context.push('/notifications')),
        ]),
        const SizedBox(height: 24),
        Row(children: [
          Text('Lists', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New List',
            onPressed: () async {
              final name = await _prompt(context, 'New list name');
              if (name != null && context.mounted) context.read<TasksCubit>().addList(name);
            },
          )
        ]),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: lists.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No lists')))
              : Column(children: [
                  for (final entry in lists.entries)
                    ListTile(
                      leading: const Icon(Icons.list_outlined),
                      title: Text(entry.value),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/tasks/list/${entry.key}'),
                    ),
                ]),
        )
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 100,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon), const SizedBox(height: 6), Text(label)])),
        ),
      ),
    );
  }
}

Future<String?> _prompt(BuildContext context, String title) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Create')),
      ],
    ),
  );
}
