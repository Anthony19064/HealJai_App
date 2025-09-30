import 'dart:math'; // <<< 1. เพิ่ม import สำหรับการสุ่ม

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CatGameScreen extends StatefulWidget {
  const CatGameScreen({super.key});

  @override
  State<CatGameScreen> createState() => _CatGameScreenState();
}

class _CatGameScreenState extends State<CatGameScreen> {
  int _score = 0;
  int _coins = 0; // <<< 2. เพิ่มตัวแปรสำหรับเก็บเงิน

  // ฟังก์ชันเมื่อแตะหน้าจอ จะบวกคะแนนและมีโอกาสได้เงิน
  void _onTapScreen() {
    setState(() {
      _score++;

      // <<< 3. เพิ่ม Logic การสุ่มเงิน
      // สุ่มเลข 0-9 (มี 10 ตัวเลข)
      final random = Random().nextInt(10); 
      // ถ้าสุ่มได้เลข 0 (โอกาส 1 ใน 10) จะได้เงิน
      if (random == 0) {
        // สุ่มเงินที่จะได้ระหว่าง 1 ถึง 5 เหรียญ
        _coins += Random().nextInt(5) + 1;
      }
    });
  }

  // <<< 4. เพิ่ม Widget Helper สำหรับสร้างกล่องแสดงสถานะ
  Widget _buildStatDisplay(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black26, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.brown, size: 20),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5C94FC),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: _onTapScreen,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          
          // <<< 5. ลบตัวแสดงคะแนนอันเก่าออกไป
          // Positioned( ... ),

          // ปุ่มย้อนกลับ (ยังอยู่เหมือนเดิม)
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () {
                context.go('/');
              },
            ),
          ),

          // <<< 6. เพิ่มแถบแสดงสถานะใหม่ที่มุมบนขวา
          Positioned(
            top: 50,
            right: 16,
            child: Row(
              children: [
                _buildStatDisplay(Icons.star, '$_score'), // แสดงแต้ม
                const SizedBox(width: 10),
                _buildStatDisplay(Icons.monetization_on, '$_coins'), // แสดงเงิน
              ],
            ),
          )
        ],
      ),
    );
  }
}