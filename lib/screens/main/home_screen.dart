import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:healjai_project/Widgets/Home/WelcomeSection.dart';
import 'package:healjai_project/Widgets/Home/DiarySection.dart';
import 'package:healjai_project/Widgets/Home/TrackerSection.dart';
import 'package:healjai_project/providers/DiaryProvider.dart';
import 'package:healjai_project/providers/TrackerProvider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ตั้งค่าตำแหน่งเริ่มต้นของปุ่ม (X, Y)
  Offset _buttonPosition = const Offset(300, 250);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<DiaryProvider>(context, listen: false).fetchTaskCount();
      Provider.of<TrackerProvider>(context, listen: false).fetchTreeAge();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. ส่วนเนื้อหาหน้าโฮม (ปรับแก้การชิดซ้ายด้วย Center + ConstrainedBox)
        ZoomIn(
          duration: const Duration(milliseconds: 500),
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ), // คุมความกว้างสูงสุดเพื่อให้ดูดีบนจอใหญ่
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const Welcomesection(),
                      const SizedBox(height: 50),
                      const DiarySection(),
                      const SizedBox(height: 50),
                      const TreeSection(),
                      const SizedBox(
                        height: 120,
                      ), // เผื่อที่ไว้ข้างล่างไม่ให้ปุ่มบังเนื้อหาท้ายๆ
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // 2. ปุ่มลอย Draggable Chat Head พร้อมป้ายข้อความ
        Positioned(
          left: _buttonPosition.dx,
          top: _buttonPosition.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _buttonPosition += details.delta;
              });
            },
            onTap: () => context.push('/ai-chatbot'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ป้ายข้อความ "คุยกับน้องฮีลใจ"
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  margin: const EdgeInsets.only(
                    bottom: 8,
                  ), // แก้ไขจาก .bottom เป็น .only

                  child: Text(
                    'คุยกับน้องฮีลใจ',
                    style: GoogleFonts.kanit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF78B465),
                    ),
                  ),
                ),
                // แบบใหม่ (นิ่งสนิท ไม่ขยาย)
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage(
                      'assets/icons/app_icon.png',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
