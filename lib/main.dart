import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'repository/messages_repository.dart';
import 'repository/push_token_repository.dart';
import 'repository/tasks_repository.dart';
import 'router/app_router.dart';
import 'services/push_notification_service.dart';
import 'state/auth_cubit.dart';
import 'state/messages_cubit.dart';
import 'state/tasks_cubit.dart';
import 'state/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _bootstrapFirebase();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const OrgApp());
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (options != null) {
      await Firebase.initializeApp(options: options);
    } else {
      await Firebase.initializeApp();
    }
  }
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
  void dispose() {
    context.read<PushNotificationService>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => MessagesRepository()),
        RepositoryProvider(create: (_) => PushTokenRepository()),
        RepositoryProvider(create: (_) => TasksRepository()),
        RepositoryProvider(
          create: (context) => PushNotificationService(
            tokenRepository: context.read<PushTokenRepository>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(
            create: (_) => AuthCubit(firebaseAuth: FirebaseAuth.instance),
          ),
          BlocProvider(
            create: (context) => TasksCubit(
              tasksRepository: context.read<TasksRepository>(),
              messagesRepository: context.read<MessagesRepository>(),
              authCubit: context.read<AuthCubit>(),
            ),
          ),
          BlocProvider(
            create: (context) => MessagesCubit(
              repository: context.read<MessagesRepository>(),
            ),
          ),
        ],
        // Use a Builder to access the context where providers above are available
        child: Builder(
          builder: (innerContext) {
            innerContext.read<PushNotificationService>().ensureInitialized(
                  authCubit: innerContext.read<AuthCubit>(),
                  messagesCubit: innerContext.read<MessagesCubit>(),
                );
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
      ),
    );
  }
}
