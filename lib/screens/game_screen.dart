import 'package:flutter/material.dart';

import '../Widgets/header_section.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Game page"),
      ]
    );
  }
}
