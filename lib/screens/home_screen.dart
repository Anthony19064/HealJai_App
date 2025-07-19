import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../Widgets/header_section.dart';
// import '../Widgets/shortcut_buttons.dart';
// import '../Widgets/suggestion_carousel.dart';
// import '../Widgets/action_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB), // สีพื้นหลังแบบนุ่ม
      body: SafeArea(
        child: Column(
          children: const [
            HeaderSection(),
          ],
        ),
      ),

    );
  }
}
