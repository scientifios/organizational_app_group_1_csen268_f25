import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../state/tasks_cubit.dart';
import '../widgets/task_tile.dart';

class ListPage extends StatelessWidget {
  final String listId;
  const ListPage({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<TasksCubit>();
    final listName = cubit.state.lists[listId] ?? 'List';
    final items = cubit.state.tasks.where((t) => t.listId == listId).toList();
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(listName),
        actions: const [],
      ),
      floatingActionButton: FilledButton.icon(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New task'),
        onPressed: () async {
          controller.clear();
          final name = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Add to $listName'),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'New task'),
                onSubmitted: (_) => Navigator.pop(context, controller.text.trim()),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, controller.text.trim()),
                  child: const Text('Add'),
                ),
              ],
            ),
          );
          if (name != null && name.trim().isNotEmpty) {
            await cubit.addTask(name.trim(), listId: listId);
          }
          controller.clear();
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(listName, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('${items.length} tasks',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey[600])),
              const SizedBox(height: 12),
              Expanded(
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 96, top: 8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => Card(
                      elevation: 0,
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TaskTile(task: items[i]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
