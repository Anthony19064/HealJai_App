import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

// --- Game Class (โลกของ Component) ---
class WheelGame extends FlameGame {
  final VoidCallback onSpinComplete;
  late final WheelComponent wheel;

  WheelGame({required this.onSpinComplete});

  @override
  Future<void> onLoad() async {
    wheel = WheelComponent(onSpinComplete: onSpinComplete);
    add(wheel);
    wheel.position = size / 2;
  }
}

// --- Component Class (ตัววงล้อจริงๆ) ---
class WheelComponent extends SpriteComponent {
  final VoidCallback onSpinComplete;

  // =========================================================================
  // ✨ 1. ปรับความเร็วตรงนี้ (เลขน้อย = เร็วขึ้น)
  // =========================================================================
  final double _spinDuration = 3.0; // จาก 4.0 เป็น 3.0 (เร็วขึ้น)
  
  double _elapsedTime = 0;

  double _startAngle = 0;
  double _endAngle = 0;
  bool _isSpinning = false;

  WheelComponent({required this.onSpinComplete}) : super(anchor: Anchor.center);

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
    
    double targetRadians = targetDegrees * (pi / 180);
    
    // =========================================================================
    // ✨ 2. ปรับจำนวนรอบตรงนี้ (เช่น Random().nextInt(4) + 7 คือ 7-10 รอบ)
    // =========================================================================
    int randomRotations = Random().nextInt(4) + 7; // จาก 4-6 เป็น 7-10 รอบ
    
    double fullRotations = pi * 2 * randomRotations;

    double currentRevolution = (angle / (2 * pi)).floor() * (2 * pi);
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

    double easedProgress = Curves.easeOut.transform(progress);
    angle = _startAngle + (_endAngle - _startAngle) * easedProgress;
  }
}