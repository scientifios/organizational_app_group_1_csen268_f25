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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/task_detail/${task.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double iconSlot = 36;
              const double badgeSlot = 92;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: iconSlot,
                    child: Center(
                      child: showCheckbox
                          ? _AnimatedTap(
                              child: AnimatedScale(
                                scale: task.completed ? 0.96 : 1.0,
                                duration: const Duration(milliseconds: 150),
                                curve: Curves.easeOut,
                                child: Checkbox(
                                  value: task.completed,
                                  onChanged: (_) => cubit.toggleComplete(task.id),
                                ),
                              ),
                            )
                          : const Icon(Icons.radio_button_unchecked),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: task.completed ? TextDecoration.lineThrough : null,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 160),
                            opacity: task.completed ? 0.6 : 1.0,
                            child: _buildSubtitle(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: iconSlot,
                    child: _AnimatedTap(
                      child: IconButton(
                        tooltip: task.myDay ? 'Remove from My Day' : 'Add to My Day',
                        icon: Icon(task.myDay ? Icons.wb_sunny : Icons.wb_sunny_outlined),
                        onPressed: () => cubit.toggleMyDay(task.id),
                        constraints:
                            const BoxConstraints.tightFor(width: iconSlot, height: iconSlot),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: iconSlot,
                    child: _AnimatedTap(
                      child: AnimatedScale(
                        scale: task.important ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        child: IconButton(
                          icon: Icon(task.important ? Icons.star : Icons.star_border),
                          onPressed: () => cubit.toggleImportant(task.id),
                          constraints:
                              const BoxConstraints.tightFor(width: iconSlot, height: iconSlot),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: badgeSlot,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _PriorityBadge(priority: task.priority),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
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
    final text = parts.isEmpty ? 'No details' : parts.join('  •  ');
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
    );
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
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 92,
        minHeight: 32,
      ),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          priority.label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
        ),
      ),
    );
  }
}

class _AlignedActions extends StatelessWidget {
  const _AlignedActions({
    required this.task,
    required this.onToggleMyDay,
    required this.onToggleImportant,
  });

  final Task task;
  final VoidCallback onToggleMyDay;
  final VoidCallback onToggleImportant;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AnimatedTap(
          child: IconButton(
            tooltip: task.myDay ? 'Remove from My Day' : 'Add to My Day',
            icon: Icon(task.myDay ? Icons.wb_sunny : Icons.wb_sunny_outlined),
            onPressed: onToggleMyDay,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            padding: EdgeInsets.zero,
          ),
        ),
        _AnimatedTap(
          child: IconButton(
            icon: Icon(task.important ? Icons.star : Icons.star_border),
            onPressed: onToggleImportant,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            padding: EdgeInsets.zero,
          ),
        ),
        _PriorityBadge(priority: task.priority),
      ],
    );
  }
}

class _AnimatedTap extends StatefulWidget {
  const _AnimatedTap({required this.child});
  final Widget child;

  @override
  State<_AnimatedTap> createState() => _AnimatedTapState();
}

class _AnimatedTapState extends State<_AnimatedTap> with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
