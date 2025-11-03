import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'router/app_router.dart';
import 'state/theme_cubit.dart';
import 'state/auth_cubit.dart';
import 'state/tasks_cubit.dart';

void main() {
  runApp(const OrgApp());
}

class OrgApp extends StatelessWidget {
  const OrgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => TasksCubit()..seedDemoData()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          final router = AppRouter.create(context.read<AuthCubit>());
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
            routerConfig: router,
          );
        },
      ),
    );
  }
}
