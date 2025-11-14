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
    final items = cubit.state.tasks.where((t)=> t.listId == listId).toList();
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(listName),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 16, bottom: 16),
        child: FloatingActionButton(
          heroTag: 'add_task_$listId',
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 6,
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          onPressed: () async {
            controller.clear();
            final name = await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Add to $listName'),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'New task'),
                  onSubmitted: (_) =>
                      Navigator.pop(context, controller.text.trim()),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () =>
                        Navigator.pop(context, controller.text.trim()),
                    child: const Text('Add'),
                  ),
                ],
              ),
            );
            if (name != null && name.trim().isNotEmpty) {
              await cubit.addTask(
                name.trim(),
                listId: listId,
                myDay: true,
              );
            }
            controller.clear();
          },
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) => TaskTile(task: items[i]),
      ),
    );
  }
}
