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
  final double _cardRadius = 18;

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
        centerTitle: false,
        actions: const [],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 16, bottom: 16),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          icon: const Icon(Icons.add),
          label: const Text('New task'),
          onPressed: () => _showCreateDialog(cubit),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              _header(context, tasks.length),
              const SizedBox(height: 12),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_cardRadius),
                ),
                child: Column(
                  children: [
                    _buildSearchRow(),
                    const Divider(height: 1),
                    _buildFilterRow(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: tasks.isEmpty
                    ? _emptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 90, top: 8),
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _taskCard(tasks[i]),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, int count) {
    final active = _applyQuery(
      context.read<TasksCubit>().state.tasks.where((t) => !t.completed).toList(),
      context.read<TasksCubit>().state.lists,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('$count tasks · ${active.length} active',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Search',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _searchController.clear(),
                ),
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(TasksCubit cubit) async {
    _controller.clear();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('New task'),
          content: TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Title',
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Sort by',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: DropdownButton<TaskSort>(
              value: _sort,
              isDense: true,
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
          ),
        ],
      ),
    );
  }

  Widget _taskCard(Task task) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: TaskTile(task: task),
    );
  }

  Widget _emptyState() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: const SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text('No tasks match your filters.')
            ],
          ),
        ),
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
        final title = t.title.toLowerCase();
        final note = (t.note ?? '').toLowerCase();
        final listName = t.listId != null ? (lists[t.listId]?.toLowerCase() ?? '') : '';
        return title.contains(query) || note.contains(query) || listName.contains(query);
      });
    }

    final list = filtered.toList();
    switch (_sort) {
      case TaskSort.smart:
        list.sort((a, b) => a.priority.weight.compareTo(b.priority.weight));
        break;
      case TaskSort.dueDate:
        list.sort((a, b) {
          final aDue = a.dueDate ?? DateTime(9999);
          final bDue = b.dueDate ?? DateTime(9999);
          return aDue.compareTo(bDue);
        });
        break;
      case TaskSort.priority:
        list.sort((a, b) => a.priority.weight.compareTo(b.priority.weight));
        break;
      case TaskSort.created:
        list.sort((a, b) {
          final aCreated = a.createdAt ?? DateTime(1970);
          final bCreated = b.createdAt ?? DateTime(1970);
          return aCreated.compareTo(bCreated);
        });
        break;
    }
    return list;
  }
}
