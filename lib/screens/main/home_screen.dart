import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import 'package:healjai_project/Widgets/Home/WelcomeSection.dart';
import 'package:healjai_project/Widgets/Home/DiarySection.dart';
import 'package:healjai_project/Widgets/Home/TreeSection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ZoomIn(
      duration: const Duration(milliseconds: 500),
      child: SingleChildScrollView(
        child: FractionallySizedBox(
          widthFactor: 0.9,
          child: Column(
            children: [
              Welcomesection(), //slider โชว์ข้อความต่างๆ
              const SizedBox(height: 50),
              DiarySection(), // ระบบประจำวัน
              const SizedBox(height: 50),
              TreeSection(), // ระบบต้นไม้ของผู้ใช้
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
