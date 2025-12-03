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
        leading: BackButton(
          onPressed: () {
            // Always return to home shell to avoid landing on tasks root unintentionally.
            context.go('/home');
          },
        ),
        title: const Text('Important'),
        actions: const [],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Starred', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('${tasks.length} tasks',
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
                  child: grouped.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No important tasks yet.'),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 96, top: 8),
                          itemCount: grouped.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, groupIndex) {
                            final entry = grouped.entries.elementAt(groupIndex);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (entry.key != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Text(
                                      entry.key!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ...entry.value.map(
                                  (task) => Card(
                                    elevation: 0,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: TaskTile(task: task),
                                  ),
                                ),
                              ],
                            );
                          },
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
