import 'package:flutter/material.dart';

import '../Widgets/header_section.dart';
import '../Widgets/bottom_nav.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HeaderSection(),
            Text("Game page"),
          ],
        )
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}