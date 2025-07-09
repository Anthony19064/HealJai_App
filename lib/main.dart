import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const HealJaiApp());
}

class HealJaiApp extends StatelessWidget {
  const HealJaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ฮีลใจ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Mali',
        scaffoldBackgroundColor: const Color(0xFFFDF9F5),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const HomeScreen(),
    );
  }
}
