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
    final task = context
        .select((TasksCubit c) => c.state.tasks.firstWhere((t) => t.id == taskId));
    final stepController = TextEditingController();
    final dateLabel =
        task.dueDate != null ? DateFormat.yMMMEd().format(task.dueDate!) : 'No due date';
    final timeLabel =
        task.dueDate != null ? DateFormat.jm().format(task.dueDate!) : 'No time set';

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(task.title),
        actions: [
          IconButton(
            icon: Icon(task.important ? Icons.star : Icons.star_border),
            onPressed: () => context.read<TasksCubit>().toggleImportant(task.id),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Schedule', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
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
                              onPressed: () =>
                                  context.read<TasksCubit>().setDueDate(task.id, null),
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
                                final current = task.dueDate ?? DateTime.now();
                                final updatedDateTime = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  current.hour,
                                  current.minute,
                                );
                                await context
                                    .read<TasksCubit>()
                                    .setDueDate(task.id, updatedDateTime);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time),
                      title: Text(timeLabel),
                      subtitle: const Text('Due time'),
                      trailing: IconButton(
                        icon: const Icon(Icons.schedule_outlined),
                        onPressed: () async {
                          final now = DateTime.now();
                          final current = task.dueDate ?? now;
                          final picked = await showTimePicker(
                            context: context,
                            initialTime:
                                TimeOfDay(hour: current.hour, minute: current.minute),
                          );
                          if (picked != null && context.mounted) {
                            final updatedDateTime = DateTime(
                              current.year,
                              current.month,
                              current.day,
                              picked.hour,
                              picked.minute,
                            );
                            await context
                                .read<TasksCubit>()
                                .setDueDate(task.id, updatedDateTime);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ReminderSection(task: task),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Priority & Time',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<TaskPriority>(
                            value: task.priority,
                            decoration: const InputDecoration(labelText: 'Priority'),
                            items: TaskPriority.values
                                .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p.label),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                context.read<TasksCubit>().setPriority(task.id, value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subtasks', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    for (final s in task.steps)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.check_box_outline_blank),
                        title: Text(s),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: stepController,
                            decoration: const InputDecoration(hintText: 'Add a step'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            final text = stepController.text.trim();
                            if (text.isNotEmpty) {
                              await context.read<TasksCubit>().addStep(task.id, text);
                              stepController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notes', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: task.note ?? '',
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Add note',
                        labelText: 'Note',
                      ),
                      onChanged: (value) =>
                          context.read<TasksCubit>().setNote(task.id, value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderSection extends StatelessWidget {
  const _ReminderSection({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final label = _reminderLabel(task.notifyBeforeDays);
    final items = const [
      DropdownMenuItem(value: 0, child: Text('Off', overflow: TextOverflow.ellipsis)),
      DropdownMenuItem(
        value: -3,
        child: Text(
          'Repeat every 5 minutes until due (test)',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      DropdownMenuItem(
        value: -2,
        child: Text(
          '5 minutes from now (test)',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      DropdownMenuItem(
        value: -1,
        child: Text(
          'At due time (test)',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      DropdownMenuItem(value: 1, child: Text('1 day', overflow: TextOverflow.ellipsis)),
      DropdownMenuItem(value: 2, child: Text('2 days', overflow: TextOverflow.ellipsis)),
      DropdownMenuItem(value: 3, child: Text('3 days', overflow: TextOverflow.ellipsis)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder lead time',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style:
              Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: task.notifyBeforeDays.clamp(-3, 3),
          items: items,
          decoration: const InputDecoration(
            labelText: 'Choose reminder',
          ),
          isExpanded: true,
          onChanged: (value) {
            if (value != null) {
              context.read<TasksCubit>().setNotifyBeforeDays(task.id, value);
            }
          },
        ),
      ],
    );
  }
}

String _reminderLabel(int value) {
  if (value == 0) return 'Off';
  if (value == -1) return 'At due time (quick test)';
  if (value == -2) return '5 minutes from now (test)';
  if (value == -3) return 'Repeat every 5 minutes until due (test)';
  return '$value day(s) before';
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
