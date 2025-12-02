import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/auth_cubit.dart';
import '../ui/layout/app_shell.dart';
import '../ui/pages/login_page.dart';
import '../ui/pages/settings_page.dart';
import '../ui/pages/task_detail_page.dart';
import '../ui/pages/add_note_page.dart';
import '../ui/pages/create_group_page.dart';
import '../ui/pages/splash_page.dart';
import '../ui/pages/tasks_page.dart';

class AppRouter {
  static GoRouter create(AuthCubit auth) {
    return GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SplashPage()),
        ),
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
          path: '/tasks/list/:id',
          name: 'tasks_list',
          builder: (c, s) => TasksPage(listId: s.pathParameters['id']),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          pageBuilder: (context, state) => CustomTransitionPage(
            transitionDuration: const Duration(milliseconds: 220),
            reverseTransitionDuration: const Duration(milliseconds: 220),
            child: const SettingsPage(),
            transitionsBuilder: (context, animation, secondary, child) {
              final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
              final offsetTween = Tween(begin: const Offset(0.08, 0), end: Offset.zero);
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: offsetTween.animate(curved),
                  child: child,
                ),
              );
            },
          ),
        ),
        GoRoute(
          path: '/create_group',
          name: 'create_group',
          builder: (c, s) => const CreateGroupPage(),
        ),
      ],
      redirect: (c, s) {
        final loggingIn = s.fullPath == '/login';
        final onSplash = s.fullPath == '/splash';
        final authed = auth.state is Authenticated;
        if (!authed && !(loggingIn || onSplash)) return '/login';
        if (authed && onSplash) return '/home';
        return null;
      },
    );
  }

  static Widget _fade(BuildContext context, Animation<double> a, Animation<double> s, Widget child) =>
      FadeTransition(opacity: a, child: child);
}
