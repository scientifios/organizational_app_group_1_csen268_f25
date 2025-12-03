import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../model/task.dart';
import '../../state/tasks_cubit.dart';
import '../widgets/prompt_dialog.dart';
import '../widgets/task_tile.dart';

class MyDayPage extends StatelessWidget {
  const MyDayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.select((TasksCubit c) => _smartMyDay(c.state.tasks));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Day'),
        actions: const [],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today', style: Theme.of(context).textTheme.headlineMedium),
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
                  child: tasks.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No tasks in My Day yet'),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 96, top: 8),
                          itemCount: tasks.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return const ListTile(
                                title: Text("Today's focus"),
                                subtitle:
                                    Text('Sorted by urgency → importance → duration'),
                              );
                            }
                            return Card(
                              elevation: 0,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              child: TaskTile(task: tasks[index - 1]),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FilledButton.icon(
        onPressed: () async {
          final name = await promptDialog(context, 'Add task to My Day');
          if (name != null && context.mounted) {
            await context.read<TasksCubit>().addTask(name, myDay: true);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
    );
  }
}

List<Task> _smartMyDay(List<Task> tasks) {
  final today = DateTime.now();

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool shouldInclude(Task t) {
    final dueToday = t.dueDate != null && isSameDay(t.dueDate!, today);
    final overdue = t.dueDate != null && t.dueDate!.isBefore(today);
    final highValue = t.priority == TaskPriority.high || t.important;
    return !t.completed && (t.myDay || dueToday || overdue || highValue);
  }

  int urgencyScore(Task t) {
    if (t.dueDate == null) return 3;
    if (t.dueDate!.isBefore(today)) return 0;
    if (isSameDay(t.dueDate!, today)) return 1;
    return 2;
  }

  final selected = tasks.where(shouldInclude).toList();
  selected.sort((a, b) {
    final urgent = urgencyScore(a).compareTo(urgencyScore(b));
    if (urgent != 0) return urgent;
    final priority = a.priority.weight.compareTo(b.priority.weight);
    if (priority != 0) return priority;
    final estimateA = a.estimateMinutes ?? 9999;
    final estimateB = b.estimateMinutes ?? 9999;
    return estimateA.compareTo(estimateB);
  });
  return selected;
}
