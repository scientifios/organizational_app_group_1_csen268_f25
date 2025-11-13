import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../model/in_app_message.dart';
import '../../state/messages_cubit.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Messages'),
        actions: [
          IconButton(
            tooltip: 'Mark all read',
            icon: const Icon(Icons.done_all),
            onPressed: () => context.read<MessagesCubit>().markAllRead(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search messages',
              ),
              onChanged: context.read<MessagesCubit>().setQuery,
            ),
          ),
          SwitchListTile.adaptive(
            title: const Text('Unread only'),
            value: context.watch<MessagesCubit>().state.unreadOnly,
            onChanged: context.read<MessagesCubit>().toggleUnreadOnly,
          ),
          Expanded(
            child: BlocBuilder<MessagesCubit, MessagesState>(
              builder: (context, state) {
                if (state.status == MessagesStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == MessagesStatus.error) {
                  return Center(child: Text(state.error ?? 'Unable to load'));
                }
                final messages = state.visibleMessages;
                if (messages.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No messages yet'),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: messages.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final time = DateFormat('MM-dd HH:mm').format(message.createdAt);
                    final icon = _iconFor(message.category);
                    final theme = Theme.of(context);
                    return ListTile(
                      leading: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
                          ),
                          if (!message.read)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.shade400,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(message.title),
                      subtitle: Text(message.body),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            time,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (!message.read)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'NEW',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                                    ),
                              ),
                            ),
                        ],
                      ),
                      onTap: () => _showMessageDetail(context, message),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(MessageCategory category) {
  switch (category) {
    case MessageCategory.reminder:
      return Icons.alarm_on_outlined;
    case MessageCategory.tip:
      return Icons.lightbulb_outline;
    case MessageCategory.activity:
      return Icons.notifications_outlined;
  }
}

Future<void> _showMessageDetail(BuildContext context, InAppMessage message) async {
  context.read<MessagesCubit>().markRead(message.id);
  final time = DateFormat('yyyy-MM-dd HH:mm').format(message.createdAt);
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(message.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time, style: Theme.of(dialogContext).textTheme.bodySmall),
            const SizedBox(height: 12),
            Text(message.body),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Got it'),
          ),
        ],
      );
    },
  );
}
