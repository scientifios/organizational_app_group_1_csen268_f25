import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../state/tasks_cubit.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<TasksCubit>();
    final tasks = cubit.state.tasks;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()), // 
        title: const Text('Tasks'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:16, vertical: 8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Add a task'),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    cubit.addTask(_controller.text.trim());
                    _controller.clear();
                  }
                },
                child: const Text('Add'),
              ),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final t = tasks[i];
                return ListTile(
                  leading: Checkbox(
                    value: t.completed,
                    onChanged: (_) => cubit.toggleComplete(t.id),
                  ),
                  title: Text(
                    t.title,
                    style: TextStyle(
                      decoration: t.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(t.important ? Icons.star : Icons.star_border),
                    onPressed: () => cubit.toggleImportant(t.id),
                  ),
                  onTap: () => context.push('/tasks/detail/${t.id}'),
                  onLongPress: () => cubit.removeTask(t.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
