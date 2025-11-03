import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../state/tasks_cubit.dart';

class MyDayPage extends StatelessWidget {
  const MyDayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.select((TasksCubit c) => c.state.tasks.where((t)=> t.myDay).toList());
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: ()=> context.pop()), title: const Text('My Day')),
      body: ListView.separated(
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i){
          final t = tasks[i];
          return ListTile(
            title: Text(t.title),
            trailing: IconButton(icon: Icon(t.important? Icons.star : Icons.star_border), onPressed: ()=> context.read<TasksCubit>().toggleImportant(t.id)),
            onTap: ()=> context.push('/tasks/detail/${t.id}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        final name = await _prompt(context);
        if (name != null && context.mounted) context.read<TasksCubit>().addTask(name, myDay: true);
      }, child: const Icon(Icons.add)),
    );
  }
}

Future<String?> _prompt(BuildContext context) async {
  final c = TextEditingController();
  return showDialog<String>(context: context, builder: (_)=> AlertDialog(
    title: const Text('Add task to My Day'),
    content: TextField(controller: c, autofocus: true),
    actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: ()=> Navigator.pop(context, c.text.trim()), child: const Text('Add'))],
  ));
}
