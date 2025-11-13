import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../state/tasks_cubit.dart';

class ListPage extends StatelessWidget {
  final String listId;
  const ListPage({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<TasksCubit>();
    final listName = cubit.state.lists[listId] ?? 'List';
    final items = cubit.state.tasks.where((t)=> t.listId == listId).toList();
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: ()=> context.pop()), title: Text(listName)),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(children: [
            Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Add a task'))),
            const SizedBox(width: 8),
            FilledButton(onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await cubit.addTask(controller.text.trim(), listId: listId);
                controller.clear();
              }
            }, child: const Text('Add'))
          ]),
        ),
        Expanded(child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i){
            final t = items[i];
            return ListTile(
              leading: Checkbox(
                value: t.completed,
                onChanged: (_) {
                  cubit.toggleComplete(t.id);
                },
              ),
              title: Text(t.title),
              trailing: IconButton(
                icon: Icon(t.important? Icons.star : Icons.star_border),
                onPressed: () {
                  cubit.toggleImportant(t.id);
                },
              ),
              onTap: ()=> context.push('/tasks/detail/${t.id}'),
              onLongPress: () {
                cubit.removeTask(t.id);
              },
            );
          },
        ))
      ]),
    );
  }
}
