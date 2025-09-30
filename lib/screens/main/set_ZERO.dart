import 'dart:async';
import 'dart:math'; // เพิ่มสำหรับสร้างข้อมูล Leaderboard สุ่ม
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:go_router/go_router.dart';

class SetZero extends StatefulWidget {
  const SetZero({super.key});

  @override
  State<SetZero> createState() => _SetZeroState();
}

class _SetZeroState extends State<SetZero> {
  // --- Game State (ยังคงเหมือนเดิม) ---
  Artboard? _artboard;
  OneShotAnimation? _animation;
  bool _isCooldown = false;
  int _score = 0;
  bool _isLoading = true;
  late AudioPool _chopPool;

  // --- Navigation State ---
  late final PageController _pageController;

  // --- Leaderboard Data ---
  final Random _random = Random();
  late final List<Map<String, dynamic>> _leaderboardData;

  // --- ตั้งค่าไฟล์ตรงนี้ ---
  static const String _riveFile =
      'assets/animations/rives/minigame_cutting1.riv'; // ใช้ไฟล์เดิม
  static const String _leaderboardRiveFile =
      'assets/animations/rives/leaderboard.riv'; // เพิ่มไฟล์ Leaderboard
  static const String _animationName = 'play';
  static const String _soundFile = 'choptree.mp3';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // สร้างข้อมูล Leaderboard แบบสุ่ม
    _leaderboardData = List.generate(
      50,
      (index) => {
        "name": "Player ${index + 1}",
        "score": _random.nextInt(5000) + (50 - index) * 100,
      },
    )..sort((a, b) => b['score'].compareTo(a['score']));

    _loadResources();
  }

  Future<void> _loadResources() async {
    // 1. สร้าง Audio Pool เตรียมไว้
    _chopPool = await FlameAudio.createPool(
      _soundFile,
      minPlayers: 5,
      maxPlayers: 8,
    );

    // 2. โหลดไฟล์ Rive และตั้งค่า OneShotAnimation
    try {
      final data = await rootBundle.load(_riveFile);
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;

      final animation = OneShotAnimation(
        _animationName,
        autoplay: false,
        onStop: () {
          // เมื่อแอนิเมชันเล่นจบ ให้ปลด Cooldown
          if (mounted) {
            setState(() {
              _isCooldown = false;
            });
          }
        },
      );

      artboard.addController(animation);

      // เมื่อโหลดทุกอย่างเสร็จแล้ว ให้อัปเดต UI
      if (mounted) {
        setState(() {
          _artboard = artboard;
          _animation = animation;
          _isLoading = false;
        });
      }
    } catch (e) {
      // จัดการข้อผิดพลาดในการโหลดไฟล์ Rive
      print('Error loading Rive file: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _chopPool.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTapScreen() {
    // ไม่ทำงานถ้ายังโหลดไม่เสร็จ หรือยังอยู่ใน Cooldown
    if (_isLoading || _isCooldown) return;

    setState(() {
      _isCooldown = true; // เริ่ม Cooldown
      _score++;
    });

    // เล่นเสียงจาก Pool
    _chopPool.start();

    // เล่นแอนิเมชัน
    _animation?.isActive = true;
  }

  // ----------------------------------------------------
  // --- UI สำหรับหน้า Leaderboard (ปรับปรุง) ---
  // ----------------------------------------------------

  Widget _buildLeaderboardPage() {
    final screenSize = MediaQuery.of(context).size;

    // ตั้งค่าตำแหน่งสำหรับ Leaderboard data (อิงจากโค้ดเดิม)
    const double _xOffset = 0.63;
    const double _yOffset = 0.51;
    const double _widthRatio = 0.48;
    const double _heightRatio = 0.29;

    final leaderboardContent = ListView.builder(
      padding: EdgeInsets.zero, // ลบ padding เดิม
      itemCount: _leaderboardData.length,
      itemBuilder: (context, index) {
        final player = _leaderboardData[index];
        final rank = index + 1;

        // เน้นผู้เล่น 3 อันดับแรก
        final isTopThree = rank <= 3;
        final color = isTopThree ? Colors.amberAccent : Colors.white;
        final fontWeight = isTopThree ? FontWeight.bold : FontWeight.normal;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
          child: Row(
            children: [
              Text(
                "$rank.",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  player["name"],
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: fontWeight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "${player["score"]}",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFF5C94FC),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: RiveAnimation.asset(
              'assets/animations/rives/leaderboard.riv',
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: (_xOffset - (_widthRatio / 2)) * screenSize.width,
            top: (_yOffset - (_heightRatio / 2)) * screenSize.height,
            width: _widthRatio * screenSize.width,
            height: _heightRatio * screenSize.height,
            child: leaderboardContent,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.go('/'),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.brown.shade800,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              icon: const Icon(Icons.arrow_forward_ios),
              label: const Text("ไปตัดไม้กันเถอะ"),
            ),
          ),
        ],
      ),
    );
  }
  // ----------------------------------------------------
  // --- UI สำหรับหน้า Play (โค้ดเดิมของ SetZero) ---
  // ----------------------------------------------------

  Widget _buildGamePage() {
    return Scaffold(
      backgroundColor: const Color(0xFF5C94FC),
      body: SafeArea(
        child: Column(
          children: [
            // --- ส่วนแสดงคะแนน ---
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.brown, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '$_score',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // --- ส่วนแอนิเมชัน ---
            Expanded(
              child: GestureDetector(
                onTap: _onTapScreen,
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : Rive(artboard: _artboard!, fit: BoxFit.contain),
              ),
            ),
            // --- ปุ่มสลับหน้าไป Leaderboard ---
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Colors.black.withOpacity(
                    0.3,
                  ), // เพื่อให้เห็นชัดเจน
                ),
                onPressed: () {
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.leaderboard),
                label: const Text("Leaderboard"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // --- เมธอด build หลักที่ใช้ PageView ---
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // ใช้ PageView เพื่อสลับระหว่างสองหน้า
    return PageView(
      controller: _pageController,
      // ป้องกันการสไลด์ด้วยนิ้ว
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildLeaderboardPage(), // หน้า 0: Leaderboard
        _buildGamePage(), // หน้า 1: Game
      ],
    );
  }
}
