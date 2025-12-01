import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/auth_cubit.dart';
import '../ui/layout/app_shell.dart';
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
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const AppShell(),
            transitionsBuilder: _fade,
          ),
        ),
        GoRoute(
          path: '/task_detail/:id',
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
}
