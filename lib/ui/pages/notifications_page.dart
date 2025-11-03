import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: ()=> context.pop()), title: const Text('Notifications')),
      body: ListView(
        children: const [
          ListTile(leading: Icon(Icons.notification_important_outlined), title: Text('Task 3 due today')),
          ListTile(leading: Icon(Icons.notification_important_outlined), title: Text('Meeting at 10:00')),
        ],
      ),
    );
  }
}
