import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'Screens/chat_screen.dart';
import 'Screens/game_screen.dart';
import 'Screens/home_screen.dart';
import 'Screens/commu_screen.dart';
import 'Screens/book_screen.dart';
import 'Screens/login_screen.dart';
import 'Screens/regis_screen.dart';
import 'Widgets/bottom_nav.dart';

import 'providers/navState.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => NavState())],
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavBar(), // ติดไว้ตรงนี้เลย
        );
      },
      routes: [
        GoRoute(
          path: '/chat',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: ChatScreen());
          },
        ),
        GoRoute(
          path: '/game',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: GameScreen());
          },
        ),
        GoRoute(
          path: '/',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: HomeScreen());
          },
        ),
        GoRoute(
          path: '/commu',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: CommuScreen());
          },
        ),
        GoRoute(
          path: '/book',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: BookScreen());
          },
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) {
        return NoTransitionPage(child: LoginScreen());
      },
    ),
    GoRoute(
      path: '/regis',
      pageBuilder: (context, state) {
        return const NoTransitionPage(child: RegisScreen());
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}
