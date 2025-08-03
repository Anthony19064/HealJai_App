import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'Screens/chat_screen.dart';
import 'Screens/forget_password.dart';
import 'Screens/game_screen.dart';
import 'Screens/home_screen.dart';
import 'Screens/commu_screen.dart';
import 'Screens/book_screen.dart';
import 'Screens/login_screen.dart';
import 'Screens/regis_screen.dart';
import 'Widgets/bottom_nav.dart';
import 'Widgets/header_section.dart';

import 'providers/navProvider.dart';
import 'providers/userProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavState()),
        ChangeNotifierProvider(create: (_) => UserInfo()),
      ],
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      pageBuilder: (context, state, child) {
        return NoTransitionPage(
          child: Scaffold(
            backgroundColor: const Color(0xFFFFF7EB),
            body: SafeArea(
              child: Column(
                children: [HeaderSection(), Expanded(child: child)],
              ),
            ),
            bottomNavigationBar: BottomNavBar(),
          ),
        );
      },
      routes: [
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
        return NoTransitionPage(child: RegisScreenPageView());
      },
    ),
    GoRoute(
      path: '/forget_pass',
      pageBuilder: (context, state) {
        return NoTransitionPage(child: ForgetPassword());
      },
    ),
    GoRoute(
      path: '/chat',
      pageBuilder: (context, state) {
        return NoTransitionPage(child: ChatScreen());
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
