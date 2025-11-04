// // lib/ui/pages/home_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import '../../state/tasks_cubit.dart';
// import '../widgets/quick_card.dart';
// import '../widgets/prompt_dialog.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final lists = context.select((TasksCubit c) => c.state.lists);
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         Text('Home', style: Theme.of(context).textTheme.headlineMedium),
//         const SizedBox(height: 16),
//         Wrap(spacing: 12, runSpacing: 12, children: [
//           QuickCard(icon: Icons.wb_sunny_outlined, label: 'My Day', onTap: () => context.push('/tasks/myday')),
//           QuickCard(icon: Icons.star_border, label: 'Important', onTap: () => context.push('/tasks/important')),
//           QuickCard(icon: Icons.task_alt, label: 'Tasks', onTap: () => context.push('/tasks')),
//           QuickCard(icon: Icons.notifications_outlined, label: 'Notification', onTap: () => context.push('/notifications')),
//         ]),
//         const SizedBox(height: 24),
//         Row(children: [
//           Text('Lists', style: Theme.of(context).textTheme.titleLarge),
//           const Spacer(),
//           IconButton(
//             icon: const Icon(Icons.add),
//             tooltip: 'New List',
//             onPressed: () async {
//               final name = await promptDialog(context, 'New list name');
//               if (name != null && context.mounted) context.read<TasksCubit>().addList(name);
//             },
//           )
//         ]),
//         AnimatedSwitcher(
//           duration: const Duration(milliseconds: 250),
//           child: lists.isEmpty
//               ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No lists')))
//               : Column(children: [
//                   for (final entry in lists.entries)
//                     ListTile(
//                       leading: const Icon(Icons.list_outlined),
//                       title: Text(entry.value),
//                       trailing: const Icon(Icons.chevron_right),
//                       onTap: () => context.push('/tasks/list/${entry.key}'),
//                     ),
//                 ]),
//         )
//       ],
//     );
//   }
// }



// lib/ui/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../state/tasks_cubit.dart';
// import '../widgets/quick_card.dart';
import '../widgets/prompt_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const double _hPad = 16; // 统一水平内边距
    const double _trailingW = 40; // 统一 trailing 宽度，保证右缘对齐
    final lists = context.select((TasksCubit c) => c.state.lists);

    return SingleChildScrollView(
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(_hPad),
        children: [
          Text('Home', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),

          // ✅ 四个整行块，左侧图标 + 右侧文字
          Column(
            children: [
              _QuickFullRow(
                icon: Icons.wb_sunny_outlined,
                label: 'My Day',
                onTap: () => context.push('/tasks/myday'),
              ),
              const SizedBox(height: 12),
              _QuickFullRow(
                icon: Icons.star_border,
                label: 'Important',
                onTap: () => context.push('/tasks/important'),
              ),
              const SizedBox(height: 12),
              _QuickFullRow(
                icon: Icons.task_alt,
                label: 'Tasks',
                onTap: () => context.push('/tasks'),
              ),
              const SizedBox(height: 12),
              _QuickFullRow(
                icon: Icons.notifications_outlined,
                label: 'Notification',
                onTap: () => context.push('/notifications'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ✅ 标题行改为 ListTile，与下方条目使用相同 padding 规则
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero, // 外层已统一 _hPad
            title: Text('Lists', style: Theme.of(context).textTheme.titleLarge),
            trailing: SizedBox(
              width: _trailingW,
              height: _trailingW,
              child: Center(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.add),
                  tooltip: 'New List',
                  onPressed: () async {
                    final name = await promptDialog(context, 'New list name');
                    if (name != null && context.mounted) {
                      context.read<TasksCubit>().addList(name);
                    }
                  },
                ),
              ),
            ),
          ),

          const Divider(height: 1),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: lists.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No lists'),
                    ),
                  )
                : Column(
                    children: [
                      for (final entry in lists.entries)
                        ListTile(
                          contentPadding: EdgeInsets.zero, // 和标题行一致
                          leading: const Icon(Icons.list_outlined),
                          title: Text(entry.value),
                          trailing: const SizedBox(
                            width: _trailingW, // 统一右侧宽度，右缘对齐
                            child: Center(child: Icon(Icons.chevron_right)),
                          ),
                          onTap: () => context.push('/tasks/list/${entry.key}'),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// ✅ 每个整行小块组件
class _QuickFullRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickFullRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity, // 沾满整行
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}