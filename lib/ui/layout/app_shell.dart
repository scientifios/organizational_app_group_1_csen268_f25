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
  late final PageController _pageController;

  final _pages = const [
    HomePage(),
    MyDayPage(),
    TasksPage(),
    NotificationsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _setIndex(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int i) {
    if (i != _index) {
      setState(() => _index = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        final navDestinations = const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.wb_sunny_outlined), label: 'My Day'),
          NavigationDestination(icon: Icon(Icons.checklist_outlined), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), label: 'Messages'),
        ];

        final content = PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: _onPageChanged,
          children: _pages,
        );

        final scope = _TabScope(
          setIndex: _setIndex,
          index: _index,
          child: content,
        );

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => _setIndex(i),
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
            height: 68,
            selectedIndex: _index,
            onDestinationSelected: (i) => _setIndex(i),
            destinations: navDestinations,
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
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
