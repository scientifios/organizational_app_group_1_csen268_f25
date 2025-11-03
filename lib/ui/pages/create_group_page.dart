import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: ()=> context.pop()), title: const Text('Create Group')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Group name')),
            const SizedBox(height: 12),
            TextField(decoration: const InputDecoration(labelText: 'Add members (emails)', helperText: 'Comma separated')),
            const Spacer(),
            FilledButton.icon(onPressed: (){ Navigator.pop(context); }, icon: const Icon(Icons.group_add_outlined), label: const Text('Create')),
          ],
        ),
      ),
    );
  }
}
