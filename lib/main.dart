import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/commu_screen.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child; 
          },
        );
      },
    ),
    GoRoute(
      path: '/commu',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: CommuScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child; 
          },
        );
      },
    ),
    GoRoute(
      path: '/game',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: GameScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child; 
          },
        );
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}
