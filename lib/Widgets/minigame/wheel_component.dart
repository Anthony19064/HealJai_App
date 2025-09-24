import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';


class WheelGame extends FlameGame {
  final VoidCallback onSpinComplete;
  late final WheelComponent wheel;

  WheelGame({required this.onSpinComplete});

  @override
  Color backgroundColor() => const Color(0x00000000); // โปร่งใส

  @override
  Future<void> onLoad() async {
    wheel = WheelComponent(onSpinComplete: onSpinComplete);
    add(wheel);
    wheel.position = size / 2;
  }
}
// --- Wheel Component Class ---
class WheelComponent extends SpriteComponent {
  final VoidCallback onSpinComplete;

  // --- Configuration ---
  final double _spinDuration = 3.0; // ระยะเวลาหมุน (วินาที), เลขน้อย = เร็วขึ้น
  
  // --- State Variables ---
  double _elapsedTime = 0;
  double _startAngle = 0;
  double _endAngle = 0;
  bool _isSpinning = false;

  WheelComponent({required this.onSpinComplete}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('wheel.png');
    size = Vector2.all(380.0); // กำหนดขนาดของวงล้อ

    
  }

  /// Starts the spinning animation to a target degree.
  void startSpin(double targetDegrees) {
    if (_isSpinning) return;

    _elapsedTime = 0;
    _isSpinning = true;
    _startAngle = angle;
    
    final double targetRadians = targetDegrees * (pi / 180);
    
    // สุ่มจำนวนรอบที่จะหมุนเพิ่ม (เช่น 7-10 รอบ)
    final int randomRotations = Random().nextInt(4) + 7;
    final double fullRotations = pi * 2 * randomRotations;

    // คำนวณมุมสุดท้ายที่จะหยุดให้แม่นยำและหมุนไปข้างหน้าเสมอ
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

    // เมื่อหมุนครบเวลาแล้ว
    if (progress >= 1.0) {
      angle = _endAngle; // กำหนดมุมสุดท้ายให้เป๊ะ
      _isSpinning = false;
      onSpinComplete(); // แจ้งเตือนว่าหมุนเสร็จแล้ว
      return;
    }

    // ทำให้การหมุนช้าลงตอนใกล้จะหยุด (EaseOut)
    final double easedProgress = Curves.easeOut.transform(progress);
    angle = _startAngle + (_endAngle - _startAngle) * easedProgress;
  }
}