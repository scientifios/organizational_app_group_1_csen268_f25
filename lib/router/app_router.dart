import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/auth_cubit.dart';
import '../ui/layout/app_shell.dart';
import '../ui/pages/home_page.dart';
import '../ui/pages/tasks_page.dart';
import '../ui/pages/myday_page.dart';
import '../ui/pages/important_page.dart';
import '../ui/pages/list_page.dart';
import '../ui/pages/search_page.dart';
import '../ui/pages/notifications_page.dart';
import '../ui/pages/login_page.dart';
import '../ui/pages/settings_page.dart';
import '../ui/pages/task_detail_page.dart';
import '../ui/pages/add_note_page.dart';
import '../ui/pages/create_group_page.dart';

class AppRouter {
  static GoRouter create(AuthCubit auth) {
    return GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (context, state) => const NoTransitionPage(child: LoginPage()),
        ),

        // AppShell ONLY on /home
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const AppShell(child: HomePage()),
            transitionsBuilder: _fade,
          ),
        ),

        // Other pages are standalone (NO AppShell)
        GoRoute(
          path: '/tasks',
          name: 'tasks',
          pageBuilder: (c, s) => CustomTransitionPage(child: const TasksPage(), transitionsBuilder: _slideUp),
          routes: [
            GoRoute(
              path: 'myday',
              name: 'myday',
              builder: (c, s) => const MyDayPage(),
            ),
            GoRoute(
              path: 'important',
              name: 'important',
              builder: (c, s) => const ImportantPage(),
            ),
            GoRoute(
              path: 'list/:id',
              name: 'list',
              builder: (c, s) => ListPage(listId: s.pathParameters['id']!),
            ),
            GoRoute(
              path: 'detail/:id',
              name: 'task_detail',
              builder: (c, s) => TaskDetailPage(taskId: s.pathParameters['id']!),
              routes: [
                GoRoute(
                  path: 'addnote',
                  name: 'add_note',
                  builder: (c, s) => AddNotePage(taskId: s.pathParameters['id']!),
                )
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/search',
          name: 'search',
          builder: (c, s) => const SearchPage(),
        ),
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (c, s) => const NotificationsPage(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (c, s) => const SettingsPage(),
        ),
        GoRoute(
          path: '/create_group',
          name: 'create_group',
          builder: (c, s) => const CreateGroupPage(),
        ),
      ],
      redirect: (c, s) {
        final loggingIn = s.fullPath == '/login';
        final authed = auth.state is Authenticated;
        if (!authed && !loggingIn) return '/login';
        if (authed && loggingIn) return '/home';
        return null;
      },
    );
  }

  static Widget _fade(BuildContext context, Animation<double> a, Animation<double> s, Widget child) =>
      FadeTransition(opacity: a, child: child);

  static Widget _slideUp(BuildContext context, Animation<double> a, Animation<double> s, Widget child) =>
      SlideTransition(position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(a), child: child);
}
