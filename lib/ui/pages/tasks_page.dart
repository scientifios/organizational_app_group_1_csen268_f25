// lib/ui/pages/tasks_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../state/tasks_cubit.dart';
import '../../model/task.dart';
import '../widgets/task_tile.dart';

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
    final List<Task> tasks = cubit.state.tasks;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go('/home');
          }
        }),
        title: const Text('Tasks'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:16, vertical: 8),
            child: Row(children: [
              Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Add a task'))),
              const SizedBox(width: 8),
              FilledButton(onPressed: (){
                if (_controller.text.trim().isNotEmpty) {
                  cubit.addTask(_controller.text.trim());
                  _controller.clear();
                }
              }, child: const Text('Add'))
            ]),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) => TaskTile(task: tasks[i]),
            ),
          )
        ],
      ),
    );
  }
}

