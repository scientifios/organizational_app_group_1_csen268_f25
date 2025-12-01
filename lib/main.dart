import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'repository/messages_repository.dart';
import 'repository/notifications_repository.dart';
import 'repository/push_token_repository.dart';
import 'repository/reminders_repository.dart';
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

@pragma('vm:entry-point')
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
    const primaryBlue = Color(0xFF4A90E2);
    const secondaryMint = Color(0xFF45C4B0);
    const tertiaryOrange = Color(0xFFF5A623);
    const lightBackground = Color(0xFFF5F7FA);

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: secondaryMint,
        tertiary: tertiaryOrange,
        surface: Colors.white,
        background: lightBackground,
      ),
      scaffoldBackgroundColor: lightBackground,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        surfaceTintColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E6EE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E6EE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        labelStyle: const TextStyle(color: Colors.black87),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => MessagesRepository()),
        RepositoryProvider(create: (_) => NotificationsRepository()),
        RepositoryProvider(create: (_) => PushTokenRepository()),
        RepositoryProvider(create: (_) => RemindersRepository()),
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
              remindersRepository: context.read<RemindersRepository>(),
              messagesRepository: context.read<MessagesRepository>(),
              notificationsRepository: context.read<NotificationsRepository>(),
              authCubit: context.read<AuthCubit>(),
            ),
          ),
          BlocProvider(
            create: (context) => MessagesCubit(
              repository: context.read<MessagesRepository>(),
            ),
          ),
        ],
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
                  theme: baseTheme,
                  darkTheme: ThemeData.dark(),
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
