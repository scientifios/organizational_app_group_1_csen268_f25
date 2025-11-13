import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../state/tasks_cubit.dart';

class AddNotePage extends StatefulWidget {
  final String taskId;
  const AddNotePage({super.key, required this.taskId});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    final note = context.read<TasksCubit>().state.tasks.firstWhere((t)=> t.id == widget.taskId).note ?? '';
    controller = TextEditingController(text: note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: ()=> context.pop()), title: const Text('Add note')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(hintText: 'Write something...', border: OutlineInputBorder()),
            )),
            const SizedBox(height: 12),
            Row(children: [
              IconButton(onPressed: (){}, icon: const Icon(Icons.add_photo_alternate_outlined)),
              IconButton(onPressed: (){}, icon: const Icon(Icons.photo_camera_outlined)),
              IconButton(onPressed: (){}, icon: const Icon(Icons.mic_none_outlined)),
              const Spacer(),
              FilledButton(onPressed: () async {
                await context.read<TasksCubit>().setNote(widget.taskId, controller.text);
                if (mounted) {
                  context.pop();
                }
              }, child: const Text('Save'))
            ])
          ],
        ),
      ),
    );
  }
}
