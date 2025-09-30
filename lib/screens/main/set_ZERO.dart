import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:flame_audio/flame_audio.dart';

class SetZero extends StatefulWidget {
  const SetZero({super.key});

  @override
  State<SetZero> createState() => _SetZeroState();
}

class _SetZeroState extends State<SetZero> {
  Artboard? _artboard;
  OneShotAnimation? _animation;
  bool _isCooldown = false;
  int score = 0;
  bool _isLoading = true; // เพิ่มสถานะการโหลด
  Timer? _debounceTimer;
  final Duration _debounceDuration = const Duration(milliseconds: 3000);
  
  // ประกาศ AudioPool ด้วย late เพื่อให้แน่ใจว่าถูกกำหนดค่าใน initState
  late AudioPool _chopPool; 

  // แนะนำให้ใช้ .ogg หรือ .wav สำหรับ SFX สั้นๆ เพื่อลด Latency
  static const String _soundFile = 'choptree.mp3'; 
  static const String _riveFile = 'assets/animations/rives/minigame_cutting.riv';

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  // ใช้ FutureBuilder เพื่อรอการโหลดทั้งหมด
  Future<void> _loadResources() async {
    // --- 1. โหลด Audio Pool ---
    // สร้าง Pool ของ Audio Player 5 ตัวล่วงหน้า
    _chopPool = await FlameAudio.createPool(
      _soundFile,
      minPlayers: 5, // จำนวน Player ขั้นต่ำที่เตรียมไว้
      maxPlayers: 8, // จำนวน Player สูงสุดที่อนุญาตให้เล่นซ้อนกัน (ปรับได้ตามความถี่)
    );
    
    // --- 2. โหลดไฟล์ Rive ---
    final data = await rootBundle.load(_riveFile);
    final file = RiveFile.import(data);
    final artboard = file.mainArtboard;

    final animation = OneShotAnimation(
      'play', // ชื่อ animation ใน Rive
      autoplay: false,
      onStop: () {
        // เมื่อ animation จบ (ซึ่งเป็นเวลาที่ปลอดภัยกว่า) ให้ปลด Cooldown
        if(mounted) {
             setState(() {
                _isCooldown = false; 
             });
        }
      },
    );

    artboard.addController(animation);

    if(mounted) {
      setState(() {
        _artboard = artboard;
        _animation = animation;
        _isLoading = false; // โหลดเสร็จแล้ว
      });
    }
  }

  // ต้อง release pool เมื่อ Widget ถูกทำลาย
  @override
  void dispose() {
    _chopPool.dispose();
    super.dispose();
  }

  void _playAnimationAndSound() {
    if (_isCooldown || _isLoading) return; // ไม่ทำงานขณะ Cooldown หรือกำลังโหลด

    _isCooldown = true;

    // --- เล่นเสียง: ใช้ AudioPool.start() ---
    // ดึง Audio Player ที่เตรียมไว้ใน Pool มาเล่นทันที ไม่มี Latency จากการสร้าง/โหลด
    _chopPool.start(); 

    // เล่น animation
    _animation?.isActive = true;
    setState(() {
      score++;
    });
    
    // **หมายเหตุ:** เราย้ายการปลด Cooldown ไปไว้ใน onStop ของ Rive Animation
    // เพื่อให้มั่นใจว่าเสียงและภาพทำงานสอดคล้องกัน (ถ้า animation สั้นพอ)
    // หากต้องการความถี่ที่เร็วกว่า ให้ใช้ Timer ในการปลด Cooldown แทน onStop

    if (_debounceTimer?.isActive ?? false) {
        _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(_debounceDuration, () {
        print(score);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Score: $score',
                style: const TextStyle(fontSize: 24, color: Colors.black),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _playAnimationAndSound,
                child: _isLoading // แสดง Loading หากยังโหลดไม่เสร็จ
                    ? const Center(child: CircularProgressIndicator())
                    : Rive(
                        artboard: _artboard!,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}