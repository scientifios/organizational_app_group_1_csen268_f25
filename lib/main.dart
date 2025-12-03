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

    final textTheme = Typography.englishLike2021.apply(
      fontFamily: 'Inter',
      displayColor: const Color(0xFF111827),
      bodyColor: const Color(0xFF111827),
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      fontFamilyFallback: const ['Roboto', 'Noto Sans SC'],
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: secondaryMint,
        tertiary: tertiaryOrange,
        surface: Colors.white,
        background: lightBackground,
      ),
      scaffoldBackgroundColor: lightBackground,
      textTheme: textTheme.copyWith(
        headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
        bodySmall: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        labelSmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
        elevation: 0.5,
        surfaceTintColor: Colors.white,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primaryBlue.withOpacity(0.15),
        elevation: 8,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          final active = states.contains(MaterialState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? primaryBlue : const Color(0xFF6B7280),
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          final active = states.contains(MaterialState.selected);
          return IconThemeData(
            color: active ? primaryBlue : const Color(0xFF6B7280),
            size: active ? 24 : 22,
          );
        }),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: lightBackground,
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
        labelStyle: const TextStyle(color: Color(0xFF111827)),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
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
        visualDensity: VisualDensity.compact,
      ),
    );
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
      primary: primaryBlue,
      secondary: secondaryMint,
      tertiary: tertiaryOrange,
    );
    final darkTheme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      fontFamilyFallback: const ['Roboto', 'Noto Sans SC'],
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: const Color(0xFF111318),
      textTheme: textTheme.copyWith(
        headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: const TextStyle(fontSize: 14, color: Color(0xFFCBD5E1)),
        bodySmall: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        labelSmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1C1F26),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C1F26),
        foregroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Color(0xFF1C1F26),
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1C1F26),
        indicatorColor: primaryBlue.withOpacity(0.2),
        elevation: 8,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          final active = states.contains(MaterialState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? Colors.white : const Color(0xFF94A3B8),
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          final active = states.contains(MaterialState.selected);
          return IconThemeData(
            color: active ? Colors.white : const Color(0xFF94A3B8),
            size: active ? 24 : 22,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C1F26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2E323D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2E323D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
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
        visualDensity: VisualDensity.compact,
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
                  darkTheme: darkTheme,
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
