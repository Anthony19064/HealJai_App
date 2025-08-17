import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'Screens/main/chat_screen.dart';
import 'Screens/main/game_screen.dart';
import 'Screens/main/home_screen.dart';
import 'Screens/main/commu_screen.dart';
import 'Screens/main/book_screen.dart';

import 'Screens/authen/forget_password.dart';
import 'Screens/authen/login_screen.dart';
import 'Screens/authen/regis_screen.dart';

import 'screens/chatroom_screen.dart';
import 'screens/mood_tracker_screen.dart';
// vvvv 1. เพิ่ม import สำหรับหน้ารายละเอียดบทความ vvvv
import 'screens/article_detail_screen.dart'; 

import 'Widgets/bottom_nav.dart';
import 'Widgets/header_section.dart';

import 'providers/navProvider.dart';
import 'providers/userProvider.dart';
import 'providers/ResetProvider.dart';
import 'providers/chatProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Navprovider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ResetProvider()),
        ChangeNotifierProvider(create: (_) => Chatprovider()),
      ],
      child: const MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: shellNavigatorKey,
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
        GoRoute(
          path: '/mood-tracker',
          builder: (context, state) => const MoodTrackerScreen(),
        ),
      ],
    ),
    
    // vvvv 2. เพิ่ม GoRoute สำหรับหน้ารายละเอียดบทความ vvvv
    GoRoute(
      path: '/book/:title', //:title คือ path parameter
      builder: (context, state) {
        // ดึงค่า title จาก path ที่ส่งมา
        final title = state.pathParameters['title']!;
        return ArticleDetailScreen(title: title);
      },
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
      routes: [
        GoRoute(
          path: 'room/:role',
          pageBuilder: (context, state) {
            final role = state.pathParameters['role']!;
            return NoTransitionPage(child: ChatRoomScreen(role: role));
          },
        ),
      ],
    ),
    GoRoute(
      path: '/mood-tracker', 
      pageBuilder: (context, state) {
        return NoTransitionPage(child: MoodTrackerScreen());
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