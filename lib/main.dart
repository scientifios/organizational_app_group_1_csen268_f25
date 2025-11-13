import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';
import 'state/theme_cubit.dart';
import 'state/auth_cubit.dart';
import 'state/tasks_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _bootstrapFirebase();
  runApp(const OrgApp());
}

Future<void> _bootstrapFirebase() async {
  final options = DefaultFirebaseOptions.currentPlatform;
  if (options != null) {
    await Firebase.initializeApp(options: options);
    return;
  }

  if (kIsWeb) {
    throw StateError(
      'Firebase is not configured for Web. Run `flutterfire configure` to '
      'generate firebase_options.dart or provide FirebaseOptions manually.',
    );
  }

  await Firebase.initializeApp();
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
        BlocProvider(
          create: (_) => AuthCubit(firebaseAuth: FirebaseAuth.instance),
        ),
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
