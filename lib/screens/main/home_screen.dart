import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import 'package:healjai_project/Widgets/Home/WelcomeSection.dart';
import 'package:healjai_project/Widgets/Home/DiarySection.dart';
import 'package:healjai_project/Widgets/Home/TreeSection.dart';
import 'package:healjai_project/providers/DiaryProvider.dart';
import 'package:healjai_project/providers/TreeProvider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<DiaryProvider>(context, listen: false).fetchTaskCount();
      Provider.of<TreeProvider>(context, listen: false).fetchTreeAge();
    });
  }


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
