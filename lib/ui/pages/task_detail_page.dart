import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'dart:io';
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
                    const SizedBox(height: 12),
                    _NoteAttachment(task: task),
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
        value: -1,
        child: Text(
          'At due time',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];
    final dropdownValue = task.notifyBeforeDays == -1 ? -1 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder lead time',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          _reminderLabel(dropdownValue),
          style:
              Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: dropdownValue,
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
    if (value == -1) return 'At due time';
    return 'Off';
  }

class _NoteAttachment extends StatefulWidget {
  const _NoteAttachment({required this.task});

  final Task task;

  @override
  State<_NoteAttachment> createState() => _NoteAttachmentState();
}

class _NoteAttachmentState extends State<_NoteAttachment> {
  bool _uploading = false;
  late List<String> _urls;

  @override
  void initState() {
    super.initState();
    _urls = List.of(widget.task.noteImageUrls);
  }

  @override
  void didUpdateWidget(covariant _NoteAttachment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.noteImageUrls != widget.task.noteImageUrls) {
      _urls = List.of(widget.task.noteImageUrls);
    }
  }

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      await context
          .read<TasksCubit>()
          .setNoteImage(widget.task.id, File(picked.path));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo attached to note.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to attach photo.')),
      );
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  Future<void> _removeAll() async {
    setState(() {
      _uploading = true;
      _urls = [];
    });
    try {
      await context.read<TasksCubit>().clearNoteImage(widget.task.id);
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _chooseSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null && mounted) {
      await _pick(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _urls.isNotEmpty;
    final canAdd = !_uploading && _urls.length < 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: canAdd ? _chooseSource : null,
              icon: const Icon(Icons.camera_alt_outlined),
              label: _uploading
                  ? const Text('Uploading...')
                  : Text(hasImage ? 'Add photo' : 'Add photo'),
            ),
            if (hasImage) ...[
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: _uploading ? null : _removeAll,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove all'),
              ),
            ],
          ],
        ),
        if (hasImage) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _urls
                .map(
                  (u) => _NoteThumb(
                    url: u,
                    onRemove: _uploading
                        ? null
                        : () async {
                            setState(() {
                              _urls = _urls.where((e) => e != u).toList();
                              _uploading = true;
                            });
                            try {
                              await context
                                  .read<TasksCubit>()
                                  .removeNoteImage(widget.task.id, u);
                            } catch (_) {
                              // ignore
                            } finally {
                              if (mounted) setState(() => _uploading = false);
                            }
                          },
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _NoteThumb extends StatelessWidget {
  const _NoteThumb({required this.url, this.onRemove});

  final String url;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 120,
            height: 90,
            child: Image.network(url, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
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
