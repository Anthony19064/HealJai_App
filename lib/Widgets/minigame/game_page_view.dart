// lib/widgets/minigame/game_page_view.dart

import 'package:animate_do/animate_do.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:healjai_project/widgets/minigame/wheel_component.dart';
import 'package:rive/rive.dart' as rive;

class GamePageView extends StatelessWidget {
  final double wheelSize;
  final WheelGame wheelGame;
  final Color pointerColor;
  final bool isSpinning;
  final VoidCallback onSpin;
  final VoidCallback onScrollDown;

  const GamePageView({
    super.key,
    required this.wheelSize,
    required this.wheelGame,
    required this.pointerColor,
    required this.isSpinning,
    required this.onSpin,
    required this.onScrollDown,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const SizedBox.expand(
          child: rive.RiveAnimation.asset(
            'assets/animations/rives/backgroud_ani.riv',
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: _buildWheelWithPointer(),
                ),
                _buildSpinButton(),
                const Spacer(flex: 2),
                IconButton(
                  onPressed: onScrollDown,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWheelWithPointer() {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: wheelSize,
          height: wheelSize,
          child: ClipOval(child: GameWidget(game: wheelGame)),
        ),
        Positioned(
          top: -20,
          child: Icon(
            Icons.arrow_drop_down,
            size: 100,
            color: pointerColor,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpinButton() {
    return BounceInUp(
      child: GestureDetector(
        onTap: isSpinning ? null : onSpin,
        child: Image.asset('assets/images/spin_1.png', width: 200),
      ),
    );
  }
}