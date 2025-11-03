// lib/ui/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../state/tasks_cubit.dart';
import '../widgets/quick_card.dart';
import '../widgets/prompt_dialog.dart';

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
          QuickCard(icon: Icons.wb_sunny_outlined, label: 'My Day', onTap: () => context.push('/tasks/myday')),
          QuickCard(icon: Icons.star_border, label: 'Important', onTap: () => context.push('/tasks/important')),
          QuickCard(icon: Icons.task_alt, label: 'Tasks', onTap: () => context.push('/tasks')),
          QuickCard(icon: Icons.notifications_outlined, label: 'Notification', onTap: () => context.push('/notifications')),
        ]),
        const SizedBox(height: 24),
        Row(children: [
          Text('Lists', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New List',
            onPressed: () async {
              final name = await promptDialog(context, 'New list name');
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

