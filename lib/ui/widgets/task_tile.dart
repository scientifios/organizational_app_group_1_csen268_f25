// lib/ui/widgets/task_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../state/tasks_cubit.dart';
import '../../model/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final bool showCheckbox;
  const TaskTile({super.key, required this.task, this.showCheckbox = true});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TasksCubit>();
    return ListTile(
      leading: showCheckbox
          ? Checkbox(value: task.completed, onChanged: (_) => cubit.toggleComplete(task.id))
          : const Icon(Icons.radio_button_unchecked),
      title: Text(task.title, style: TextStyle(decoration: task.completed ? TextDecoration.lineThrough : null)),
      trailing: IconButton(
        icon: Icon(task.important ? Icons.star : Icons.star_border),
        onPressed: () => cubit.toggleImportant(task.id),
      ),
      onTap: () => context.push('/tasks/detail/${task.id}'),
      onLongPress: () => cubit.removeTask(task.id),
    );
  }
}
