import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizational App'),
        leading: IconButton(
          icon: const CircleAvatar(child: Icon(Icons.person, size: 18)),
          onPressed: () => context.push('/settings'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => context.push('/search')),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.push('/notifications')),
        ],
      ),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: child),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'copilot',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const _CopilotSheet(),
            ),
            child: const Icon(Icons.smart_toy_outlined),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'group',
            onPressed: () => context.push('/create_group'),
            label: const Text('Group'),
            icon: const Icon(Icons.group_add_outlined),
          ),
        ],
      ),
      // bottomNavigationBar: NavigationBar(
      //   selectedIndex: 0, // Only visible on /home now
      //   destinations: const [
      //     NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
      //     NavigationDestination(icon: Icon(Icons.check_circle_outline), label: 'Tasks'),
      //   ],
      //   onDestinationSelected: (i) {
      //     switch (i) {
      //       case 0: context.go('/home'); break;
      //       case 1: context.go('/tasks'); break;
      //     }
      //   },
      // ),
    );
  }
}

class _CopilotSheet extends StatelessWidget {
  const _CopilotSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: .6,
      maxChildSize: .95,
      minChildSize: .4,
      expand: false,
      builder: (_, controller) => Material(
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: const [
            ListTile(leading: Icon(Icons.smart_toy), title: Text('Copilot'), subtitle: Text('How can I help you today?')),
            TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.message_outlined), hintText: 'Ask anything...')),
            SizedBox(height: 12),
            ListTile(leading: Icon(Icons.lightbulb_outline), title: Text('Tip: Try "Plan my day"')),
          ],
        ),
      ),
    );
  }
}
