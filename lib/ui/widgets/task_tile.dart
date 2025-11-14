// lib/ui/widgets/task_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../model/task.dart';
import '../../state/tasks_cubit.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final bool showCheckbox;
  const TaskTile({super.key, required this.task, this.showCheckbox = true});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TasksCubit>();
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBackground(context),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => cubit.removeTask(task.id),
      child: ListTile(
        leading: showCheckbox
            ? Checkbox(
                value: task.completed,
                onChanged: (_) {
                  cubit.toggleComplete(task.id);
                },
              )
            : const Icon(Icons.radio_button_unchecked),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: _buildSubtitle(context),
        trailing: Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              tooltip: task.myDay ? 'Remove from My Day' : 'Add to My Day',
              icon: Icon(
                task.myDay ? Icons.wb_sunny : Icons.wb_sunny_outlined,
              ),
              onPressed: () => cubit.toggleMyDay(task.id),
            ),
            IconButton(
              icon: Icon(task.important ? Icons.star : Icons.star_border),
              onPressed: () {
                cubit.toggleImportant(task.id);
              },
            ),
            _PriorityBadge(priority: task.priority),
          ],
        ),
        onTap: () => context.push('/tasks/detail/${task.id}'),
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final parts = <String>[];
    if (task.dueDate != null) {
      final dueText = DateFormat.MMMd().format(task.dueDate!);
      parts.add('Due $dueText');
    }
    if (task.estimateMinutes != null) {
      parts.add('${task.estimateMinutes} min');
    }
    if (task.steps.isNotEmpty) {
      parts.add('${task.steps.length} subtask${task.steps.length == 1 ? '' : 's'}');
    }
    if (parts.isEmpty) return null;
    return Text(parts.join(' | '));
  }

  Widget _buildDeleteBackground(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task'),
        content: Text('“${task.title}” will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final TaskPriority priority;

  Color _resolveColor() {
    switch (priority) {
      case TaskPriority.high:
        return const Color(0xFFDC2626);
      case TaskPriority.medium:
        return const Color(0xFFF97316);
      case TaskPriority.low:
        return const Color(0xFF16A34A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor();
    const textColor = Color(0xFF111827);
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: SizedBox(
        width: 72,
        child: Chip(
          label: Center(child: Text(priority.label)),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          labelStyle: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
          backgroundColor: color.withOpacity(0.2),
          side: BorderSide(color: color.withOpacity(0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
