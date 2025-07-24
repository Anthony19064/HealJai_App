import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';


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
        ZoomIn(
          duration: Duration(milliseconds: 500),
          child: Text("Game page")),
      ]
    );
  }
}
