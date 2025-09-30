import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healjai_project/Widgets/bottom_nav.dart';
import 'package:rive/rive.dart';

class Island extends StatelessWidget {
  const Island({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(),
      extendBodyBehindAppBar: true, // 👈 ให้ background ล้นไปถึงด้านบน
      appBar: AppBar(
        title: const Text('My Island'),
        backgroundColor: Colors.transparent, // 👈 โปร่งใสเพื่อเห็น Rive
        elevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // 🔹 พื้นหลังเป็น Rive เต็มจอ
          const RiveAnimation.asset(
            'assets/animations/rives/backgroud_island.riv', // ✅ ใช้ชื่อไฟล์จริงให้ตรง
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
