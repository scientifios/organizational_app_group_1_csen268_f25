import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../state/tasks_cubit.dart';
import '../pages/home_page.dart';
import '../pages/myday_page.dart';
import '../pages/tasks_page.dart';
import '../pages/notifications_page.dart';

/// Adaptive shell with persistent tabs: Home / My Day / Tasks / Messages.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    MyDayPage(),
    TasksPage(),
    NotificationsPage(),
  ];

  void setIndex(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        final content = IndexedStack(index: _index, children: _pages);
        final navDestinations = const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.wb_sunny_outlined), label: 'My Day'),
          NavigationDestination(icon: Icon(Icons.checklist_outlined), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), label: 'Messages'),
        ];

        final scope = _TabScope(
          setIndex: setIndex,
          index: _index,
          child: content,
        );

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setIndex(i),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.wb_sunny_outlined),
                      selectedIcon: Icon(Icons.wb_sunny),
                      label: Text('My Day'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.checklist_outlined),
                      selectedIcon: Icon(Icons.checklist),
                      label: Text('Tasks'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.notifications_outlined),
                      selectedIcon: Icon(Icons.notifications),
                      label: Text('Messages'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: scope),
              ],
            ),
          );
        }

        return Scaffold(
          body: scope,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setIndex(i),
            destinations: navDestinations,
          ),
        );
      },
    );
  }
}

class _TabScope extends InheritedWidget {
  const _TabScope({required super.child, required this.setIndex, required this.index});

  final void Function(int) setIndex;
  final int index;

  static _TabScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_TabScope>();

  @override
  bool updateShouldNotify(covariant _TabScope oldWidget) => index != oldWidget.index;
}

/// Helper to switch tabs from child pages (e.g., Home shortcuts).
void switchToTab(BuildContext context, int index) {
  _TabScope.of(context)?.setIndex(index);
}
