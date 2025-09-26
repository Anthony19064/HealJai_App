import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

// --- Game Class ---
class WheelGame extends FlameGame {
  final VoidCallback onSpinComplete;
  // เพิ่ม Callback สำหรับส่งข้อมูลมุม
  final Function(double angle) onAngleChanged;

  late final WheelComponent wheel;

  WheelGame({
    required this.onSpinComplete,
    required this.onAngleChanged,
  });
  
  @override
  Color backgroundColor() => const Color(0x00000000); // โปร่งใส

  @override
  Future<void> onLoad() async {
    
    // ส่ง Callback ไปให้ WheelComponent
    wheel = WheelComponent(
      onSpinComplete: onSpinComplete,
      onAngleChanged: onAngleChanged,
    );
    add(wheel);
    wheel.position = size / 2;
  }
}

// --- Wheel Component Class ---
class WheelComponent extends SpriteComponent {
  final VoidCallback onSpinComplete;
  // พิ่ม Callback สำหรับส่งข้อมูลมุม
  final Function(double angle) onAngleChanged;

  final double _spinDuration = 3.0;
  double _elapsedTime = 0;
  double _startAngle = 0;
  double _endAngle = 0;
  bool _isSpinning = false;

  WheelComponent({
    required this.onSpinComplete,
    required this.onAngleChanged,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('wheel.png');
    size = Vector2.all(380.0);
  }

  void startSpin(double targetDegrees) {
    if (_isSpinning) return;
    _elapsedTime = 0;
    _isSpinning = true;
    _startAngle = angle;
    final double targetRadians = targetDegrees * (pi / 180);
    final int randomRotations = Random().nextInt(4) + 7;
    final double fullRotations = pi * 2 * randomRotations;
    final double currentRevolution = (angle / (2 * pi)).floor() * (2 * pi);
    _endAngle = currentRevolution + fullRotations + targetRadians;
    if (_endAngle < _startAngle) {
      _endAngle += (2 * pi);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_isSpinning) return;

    _elapsedTime += dt;
    double progress = _elapsedTime / _spinDuration;

    if (progress >= 1.0) {
      angle = _endAngle;
      _isSpinning = false;
      onSpinComplete();
      return;
    }

    final double easedProgress = Curves.easeOut.transform(progress);
    angle = _startAngle + (_endAngle - _startAngle) * easedProgress;

    //เรียกใช้ Callback เพื่อส่งค่ามุมกลับไปทุก frame
    onAngleChanged(angle);
  }
}