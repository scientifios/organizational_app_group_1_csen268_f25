import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../state/tasks_cubit.dart';

/// Adaptive shell: NavigationRail on wide screens, BottomNavigationBar on phones.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  static const _navItems = [
    _NavItem('Home', Icons.home_outlined, '/home'),
    _NavItem('My Day', Icons.wb_sunny_outlined, '/tasks/myday'),
    _NavItem('Tasks', Icons.checklist_outlined, '/tasks'),
    _NavItem('Messages', Icons.notifications_outlined, '/notifications'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        if (isWide) {
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex(context),
                onDestinationSelected: (index) =>
                    _onDestinationSelected(context, index),
                labelType: NavigationRailLabelType.all,
                destinations: _navItems
                    .map(
                      (item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(
                          item.icon,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: Text(item.label),
                      ),
                    )
                    .toList()
                  ..add(
                    const NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
          );
        }
        // Mobile bottom navigation
        final selected = _selectedIndex(context);
        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: selected,
            onDestinationSelected: (index) =>
                _onDestinationSelected(context, index),
            destinations: _navItems
                .map(
                  (item) => NavigationDestination(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/home')) return 0;
    if (loc.startsWith('/tasks/myday')) return 1;
    if (loc.startsWith('/tasks')) return 2;
    if (loc.startsWith('/notifications')) return 3;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    if (index < _navItems.length) {
      context.go(_navItems[index].path);
    }
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String path;
  const _NavItem(this.label, this.icon, this.path);
}
