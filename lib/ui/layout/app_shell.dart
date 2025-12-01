import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth_cubit.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizational App'),
        leading: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final user = state is Authenticated ? state.user : null;
            final avatarUrl = user?.avatarUrl ?? '';
            final hasAvatar = avatarUrl.isNotEmpty;
            return IconButton(
              icon: hasAvatar
                  ? CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(avatarUrl),
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceVariant,
                    )
                  : const CircleAvatar(
                      radius: 16,
                      child: Icon(Icons.person, size: 18),
                    ),
              onPressed: () => context.push('/settings'),
              tooltip: 'Settings',
            );
          },
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => context.push('/search')),
          IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.push('/notifications')),
        ],
      ),
      body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250), child: child),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: FloatingActionButton.small(
          heroTag: 'copilot',
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 32, vertical: 120),
              child: _CopilotSheet(),
            ),
          ),
          child: const Icon(Icons.smart_toy_outlined),
        ),
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
            // 1) 头行
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.smart_toy),
              title: Text('Copilot'),
              subtitle: Text('How can I help you today?'),
            ),

            // 2) 输入行（也用 ListTile）
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.message_outlined),
              title: TextField(
                decoration: InputDecoration(
                  hintText: 'Ask anything...',
                  border: InputBorder.none,         // 去掉下划线
                  isDense: true,
                  contentPadding: EdgeInsets.zero,  // 去掉 TextField 自身内边距
                ),
              ),
            ),

            Divider(height: 16),

            // 3) Tip 行
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.lightbulb_outline),
              title: Text('Tip: Try "Plan my day"'),
            ),
          ],
        ),
      ),
    );
  }
}
