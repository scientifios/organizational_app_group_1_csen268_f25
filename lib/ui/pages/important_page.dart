import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../model/task.dart';
import '../../state/tasks_cubit.dart';
import '../widgets/task_tile.dart';

class ImportantPage extends StatelessWidget {
  const ImportantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<TasksCubit>();
    final tasks = cubit.state.tasks
        .where((t) => t.important)
        .toList()
      ..sort((a, b) => a.priority.weight.compareTo(b.priority.weight));
    final grouped = _groupByList(tasks, cubit.state.lists);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Important'),
      ),
      body: grouped.isEmpty
          ? const Center(child: Text('No important tasks yet.'))
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                for (final entry in grouped.entries) ...[
                  if (entry.key != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        entry.key!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ...entry.value.map(
                    (task) => TaskTile(task: task),
                  ),
                  const Divider(height: 1),
                ]
              ],
            ),
    );
  }
}

Map<String?, List<Task>> _groupByList(
  List<Task> tasks,
  Map<String, String> lists,
) {
  final result = <String?, List<Task>>{};
  for (final task in tasks) {
    final listName = task.listId != null ? lists[task.listId] : null;
    result.putIfAbsent(listName, () => []).add(task);
  }
  return result;
}
