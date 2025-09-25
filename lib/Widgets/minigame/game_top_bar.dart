import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rive/rive.dart' as rive;

class GameTopBar extends StatelessWidget {
  // 1. สร้างตัวแปรเพื่อรับค่า coins และ energy จากข้างนอก
  final int coins;
  final int energy;

  // 2. สร้าง Constructor เพื่อให้รับค่าได้
  const GameTopBar({
    super.key,
    required this.coins,
    required this.energy,
  });

  @override
  Widget build(BuildContext context) {
    // 3. นำโค้ดเดิมจาก buildTopBar() มาวางที่นี่
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () => context.go('/'),
        ),
        Row(
          children: [
            // 4. ใช้ค่า coins และ energy ที่ได้รับมาแสดงผล
            _buildStatChip(
              icon: SizedBox(
                width: 24,
                height: 24,
                child: rive.RiveAnimation.asset(
                  'assets/animations/rives/coins.riv',
                  fit: BoxFit.contain,
                ),
              ),
              value: NumberFormat("#,###").format(coins),
            ),
            const SizedBox(width: 8),
            _buildStatChip(
              icon: SizedBox(
                width: 24,
                height: 24,
                child: rive.RiveAnimation.asset(
                  'assets/animations/rives/energy.riv',
                  fit: BoxFit.contain,
                ),
              ),
              value: '$energy',
            ),
          ],
        ),
      ],
    );
  }

  // 5. ย้าย buildStatChip เข้ามาเป็น private method ของ Widget นี้
  Widget _buildStatChip({required Widget icon, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}