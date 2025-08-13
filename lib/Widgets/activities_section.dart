import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

// -------------------------------------------------
// Widget หลักที่แสดงโซน "กิจกรรมประจำวัน"
// -------------------------------------------------
class ActivitiesSection extends StatelessWidget {
  const ActivitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "กิจกรรมประจำวัน",
          style: GoogleFonts.mali(
            color: const Color(0xFF78B465),
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: DailyActivityCard(
                  title: 'บันทึกอารมณ์',
                  icon: Icons.sentiment_satisfied_outlined,
                  onTap: () {
                    context.go('/mood-tracker');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DailyActivityCard(
                  title: 'ไดอารี่',
                  icon: Icons.auto_stories,
                  onTap: () {
                    print('Navigate to Diary page');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DailyActivityCard(
                  title: 'เรื่องราวดีๆ',
                  icon: Icons.celebration,
                  onTap: () {
                    print('Navigate to Good Stories page');
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------
// Widget ย่อยที่ใช้ภายในไฟล์นี้ (DailyActivityCard)
// -------------------------------------------------
class DailyActivityCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const DailyActivityCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Container(
            height: 110,
            padding: const EdgeInsets.all(8), // ลด Padding ลงเล็กน้อยเพื่อให้มีที่ว่าง
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: const Color(0xFF78B465)),
                const SizedBox(height: 8),
                // 👇 แก้ไขโดยการครอบ Text ด้วย Container
                Container(
                  height: 40, // กำหนดความสูงคงที่สำหรับพื้นที่ข้อความ
                  alignment: Alignment.center, // จัดข้อความให้อยู่กลาง Container
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.mali(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}