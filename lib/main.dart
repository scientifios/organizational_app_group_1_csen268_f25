import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'router/app_router.dart';
import 'state/theme_cubit.dart';
import 'state/auth_cubit.dart';
import 'state/tasks_cubit.dart';

void main() {
  runApp(const OrgApp());
}

class OrgApp extends StatefulWidget {
  const OrgApp({super.key});

  @override
  State<OrgApp> createState() => _OrgAppState();
}

class _OrgAppState extends State<OrgApp> {
  GoRouter? _router;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => TasksCubit()..seedDemoData()),
      ],
      // Use a Builder to access the context where providers above are available
      child: Builder(
        builder: (innerContext) {
          _router ??= AppRouter.create(innerContext.read<AuthCubit>());
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Organizational App (UI)',
                themeMode: mode,
                theme: ThemeData(
                  useMaterial3: true,
                  colorSchemeSeed: Colors.indigo,
                  brightness: Brightness.light,
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  colorSchemeSeed: Colors.indigo,
                  brightness: Brightness.dark,
                ),
                routerConfig: _router!,
              );
            },
          );
        },
      ),
    );
  }
}
