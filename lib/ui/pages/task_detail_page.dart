import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../model/task.dart';
import '../../state/tasks_cubit.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskId;
  const TaskDetailPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final task = context.select((TasksCubit c) => c.state.tasks.firstWhere((t)=> t.id == taskId));
    final stepController = TextEditingController();
    final dateLabel = task.dueDate != null ? DateFormat.yMMMEd().format(task.dueDate!) : 'No due date';
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
            leading: const Icon(Icons.event_outlined),
            title: Text(dateLabel),
            subtitle: const Text('Due date'),
            trailing: Wrap(
              spacing: 4,
              children: [
                if (task.dueDate != null)
                  IconButton(
                    tooltip: 'Clear due date',
                    icon: const Icon(Icons.close),
                    onPressed: () => context.read<TasksCubit>().setDueDate(task.id, null),
                  ),
                IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(now.year - 1),
                      lastDate: DateTime(now.year + 5),
                      initialDate: task.dueDate ?? now,
                    );
                    if (picked != null && context.mounted) {
                      final normalized = DateTime(picked.year, picked.month, picked.day);
                      await context.read<TasksCubit>().setDueDate(task.id, normalized);
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Priority'),
            subtitle: Text(task.priority.label),
            trailing: DropdownButton<TaskPriority>(
              value: task.priority,
              onChanged: (value) {
                if (value != null) {
                  context.read<TasksCubit>().setPriority(task.id, value);
                }
              },
              items: TaskPriority.values
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.label),
                      ))
                  .toList(),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.timelapse_outlined),
            title: TextFormField(
              initialValue: task.estimateMinutes?.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Estimated minutes',
                hintText: 'e.g. 30',
              ),
              keyboardType: TextInputType.number,
              onFieldSubmitted: (value) {
                final trimmed = value.trim();
                final minutes = trimmed.isEmpty ? null : int.tryParse(trimmed);
                context.read<TasksCubit>().setEstimateMinutes(task.id, minutes);
              },
            ),
            subtitle: const Text('Used for My Day smart ordering'),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.note_outlined),
            title: TextFormField(
              initialValue: task.note ?? '',
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Add note',
                border: InputBorder.none,
              ),
              onChanged: (value) =>
                  context.read<TasksCubit>().setNote(task.id, value),
            ),
          ),
        ],
      ),
    );
  }
}
