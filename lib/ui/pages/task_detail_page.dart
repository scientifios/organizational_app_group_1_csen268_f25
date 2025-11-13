import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../state/tasks_cubit.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskId;
  const TaskDetailPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final task = context.select((TasksCubit c) => c.state.tasks.firstWhere((t)=> t.id == taskId));
    final stepController = TextEditingController();
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: ()=> context.pop()), title: Text(task.title), actions: [
        IconButton(
          icon: Icon(task.important? Icons.star : Icons.star_border),
          onPressed: () {
            context.read<TasksCubit>().toggleImportant(task.id);
          },
        ),
      ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Steps', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final s in task.steps) ListTile(leading: const Icon(Icons.check_box_outline_blank), title: Text(s)),
          Row(children: [
            Expanded(child: TextField(controller: stepController, decoration: const InputDecoration(hintText: 'Add a step'))),
            IconButton(icon: const Icon(Icons.add), onPressed: () async {
              if (stepController.text.trim().isNotEmpty) {
                await context.read<TasksCubit>().addStep(task.id, stepController.text.trim());
                stepController.clear();
              }
            })
          ]),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('Time range'),
            subtitle: const Text('Not set'),
            onTap: (){},
          ),
          ListTile(
            leading: const Icon(Icons.note_outlined),
            title: const Text('Add note'),
            onTap: ()=> context.push('/tasks/detail/${task.id}/addnote'),
          ),
        ],
      ),
    );
  }
}
