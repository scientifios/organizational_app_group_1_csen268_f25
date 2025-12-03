import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../state/tasks_cubit.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  bool hideCompleted = false;

  @override
  Widget build(BuildContext context) {
    final tasks = context.select((TasksCubit c) => c.state.tasks.where((t){
      final ok = t.title.toLowerCase().contains(query.toLowerCase());
      final pass = hideCompleted ? !t.completed : true;
      return ok && pass;
    }).toList());

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: ()=> context.pop()),
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search tasks'),
          onChanged: (v)=> setState(()=> query = v),
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (c)=>[
              CheckedPopupMenuItem(checked: hideCompleted, value: 'hide', child: const Text('Hide completed')),
            ],
            onSelected: (_)=> setState(()=> hideCompleted = !hideCompleted),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, i){
          final t = tasks[i];
          return ListTile(
            title: Text(t.title),
            subtitle: Text(t.completed ? 'Completed' : 'Open'),
            onTap: ()=> context.push('/task_detail/${t.id}'),
          );
        },
      ),
    );
  }
}
