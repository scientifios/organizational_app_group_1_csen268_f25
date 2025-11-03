import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../state/tasks_cubit.dart';

class ImportantPage extends StatelessWidget {
  const ImportantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.select((TasksCubit c) => c.state.tasks.where((t)=> t.important).toList());
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: ()=> context.pop()), title: const Text('Important')),
      body: ListView.separated(
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i){
          final t = tasks[i];
          return ListTile(
            title: Text(t.title),
            trailing: IconButton(icon: Icon(t.important? Icons.star : Icons.star_border), onPressed: ()=> context.read<TasksCubit>().toggleImportant(t.id)),
            onTap: ()=> context.push('/tasks/detail/${t.id}'),
            onLongPress: ()=> context.read<TasksCubit>().removeTask(t.id),
          );
        },
      ),
    );
  }
}
