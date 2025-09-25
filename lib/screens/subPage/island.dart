import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Import intl package

class Island extends StatelessWidget {
  // 1. เพิ่มตัวแปรเพื่อรับค่า
  final int coins;
  final int energy;

  // 2. แก้ไข Constructor ให้รับค่าเข้ามา
  const Island({
    super.key,
    required this.coins,
    required this.energy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Island'),
        backgroundColor: const Color(0xFF2A4758),
        elevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          _buildStatChip(
            icon: Icons.monetization_on,
            color: Colors.amber,
            value: NumberFormat("#,###").format(coins),
          ),
          const SizedBox(width: 8),
          _buildStatChip(
            icon: Icons.favorite,
            color: Colors.red,
            value: '$energy',
          ),
          const SizedBox(width: 16),
        ],
      ),
      backgroundColor: const Color(0xFF2A4758),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'นี่คือหน้า Island',
              style: TextStyle(color: Colors.white54, fontSize: 24),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => context.go('/game'),
              icon: const Icon(Icons.casino_outlined),
              label: const Text('กลับไปที่เกม'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.amber,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required Color color,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}