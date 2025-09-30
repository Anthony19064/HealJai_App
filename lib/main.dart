import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:toastification/toastification.dart';
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

import 'screens/subPage/chatroom_screen.dart';
import 'screens/subPage/moodDiary_screen.dart';
import 'screens/subPage/diaryHistory.dart';
import 'screens/subPage/questionDiary_screen.dart';
import 'screens/subPage/storyDiary_screen.dart';
import 'screens/subPage/articleDetail.dart';
import 'screens/subPage/quoteDetail.dart';

import 'Widgets/bottom_nav.dart';
import 'Widgets/header_section.dart';

import 'providers/navProvider.dart';
import 'providers/userProvider.dart';
import 'providers/ResetProvider.dart';
import 'providers/chatProvider.dart';
import 'providers/DiaryProvider.dart';
import 'providers/TrackerProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");

  runApp(
    ToastificationWrapper(
      config: ToastificationConfig(alignment: Alignment.topCenter),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Navprovider()),
          ChangeNotifierProvider.value(value: UserProvider()),
          ChangeNotifierProvider(create: (_) => ResetProvider()),
          ChangeNotifierProvider(create: (_) => Chatprovider()),
          ChangeNotifierProvider(create: (_) => DiaryProvider()),
          ChangeNotifierProvider(create: (_) => TrackerProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final GoRouter router = GoRouter(
      initialLocation: '/login',
      refreshListenable: userProvider,
      redirect: (context, state) {
        final loggedIn = userProvider.isLoggedIn;
        final loggingIn =
            state.fullPath == '/login' ||
            state.fullPath == '/regis' ||
            state.fullPath == '/forget_pass';

        if (!loggedIn && !loggingIn) return '/login';
        if (loggedIn && loggingIn) return '/';
        return null;
      },
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
              path: '/',
              pageBuilder: (context, state) {
                return NoTransitionPage(child: HomeScreen());
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
          path: '/game',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: PlayScreen());
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
          path: '/articleInfo',
          pageBuilder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            return NoTransitionPage(child: Articledetail(data: args));
          },
        ),
        GoRoute(
          path: '/quoteInfo',
          pageBuilder: (context, state) {
            final args = state.extra as List<Map<String, String>>?;
            return NoTransitionPage(child: Quotedetail(data: args));
          },
        ),
        GoRoute(
          path: '/moodDiary',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: MoodDiaryScreen());
          },
        ),
        GoRoute(
          path: '/questionDiary',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: QuestionDiary());
          },
        ),
        GoRoute(
          path: '/storyDiary',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: StoryDiary());
          },
        ),
        GoRoute(
          path: '/diaryHistory',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: Diaryhistory());
          },
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }
}
