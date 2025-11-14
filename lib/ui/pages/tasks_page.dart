// lib/ui/pages/tasks_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../model/task.dart';
import '../../state/tasks_cubit.dart';
import '../widgets/task_tile.dart';

enum TaskFilter { all, active, completed }
enum TaskSort { smart, dueDate, priority, created }

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _controller = TextEditingController();
  final _searchController = TextEditingController();
  TaskFilter _filter = TaskFilter.all;
  TaskSort _sort = TaskSort.smart;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<TasksCubit>();
    final tasks = _applyQuery(cubit.state.tasks, cubit.state.lists);
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 16, bottom: 16),
        child: FloatingActionButton(
          heroTag: 'add_task',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          elevation: 6,
          onPressed: () => _showCreateDialog(cubit),
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchRow(),
          _buildFilterRow(),
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('No tasks match your filters.'))
                : ListView.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) => TaskTile(task: tasks[i]),
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tasks, notes or lists',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _searchController.clear(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateDialog(TasksCubit cubit) async {
    _controller.clear();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New task'),
          content: TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'What needs to get done?',
            ),
            onSubmitted: (_) => Navigator.pop(context, _controller.text.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, _controller.text.trim()),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      await cubit.addTask(result);
      _controller.clear();
    }
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final filter in TaskFilter.values)
            ChoiceChip(
              label: Text(switch (filter) {
                TaskFilter.all => 'All',
                TaskFilter.active => 'Active',
                TaskFilter.completed => 'Completed',
              }),
              selected: _filter == filter,
              onSelected: (_) => setState(() => _filter = filter),
            ),
          const SizedBox(width: 12),
          DropdownButton<TaskSort>(
            value: _sort,
            underline: const SizedBox.shrink(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _sort = value);
              }
            },
            items: TaskSort.values
                .map(
                  (sort) => DropdownMenuItem(
                    value: sort,
                    child: Text(
                      switch (sort) {
                        TaskSort.smart => 'Smart sort',
                        TaskSort.dueDate => 'Due date',
                        TaskSort.priority => 'Priority',
                        TaskSort.created => 'Created',
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  List<Task> _applyQuery(List<Task> tasks, Map<String, String> lists) {
    final query = _searchController.text.trim().toLowerCase();
    Iterable<Task> filtered = tasks;

    switch (_filter) {
      case TaskFilter.all:
        break;
      case TaskFilter.active:
        filtered = filtered.where((t) => !t.completed);
        break;
      case TaskFilter.completed:
        filtered = filtered.where((t) => t.completed);
        break;
    }

    if (query.isNotEmpty) {
      filtered = filtered.where((t) {
        final listName = t.listId != null ? lists[t.listId] ?? '' : '';
        return t.title.toLowerCase().contains(query) ||
            (t.note?.toLowerCase().contains(query) ?? false) ||
            listName.toLowerCase().contains(query);
      });
    }

    final results = filtered.toList();
    results.sort((a, b) => _compareTasks(a, b));
    return results;
  }

  int _compareTasks(Task a, Task b) {
    switch (_sort) {
      case TaskSort.smart:
        return _smartScore(a).compareTo(_smartScore(b));
      case TaskSort.dueDate:
        return _compareNullableDate(a.dueDate, b.dueDate);
      case TaskSort.priority:
        return a.priority.weight.compareTo(b.priority.weight);
      case TaskSort.created:
        return _compareNullableDate(a.createdAt, b.createdAt);
    }
  }

  int _smartScore(Task task) {
    final today = DateTime.now();
    final due = task.dueDate;
    final urgent = due != null &&
        DateTime(due.year, due.month, due.day)
                .difference(DateTime(today.year, today.month, today.day))
                .inDays <=
            0;
    final estimate = task.estimateMinutes ?? 120;
    final important = task.important || task.priority == TaskPriority.high;

    return (urgent ? 0 : 2) +
        (important ? 0 : 2) +
        (estimate ~/ 30) +
        (task.completed ? 10 : 0);
  }

  int _compareNullableDate(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }
}
