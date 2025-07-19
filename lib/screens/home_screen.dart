import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../Widgets/header_section.dart';
// import '../Widgets/shortcut_buttons.dart';
// import '../Widgets/suggestion_carousel.dart';
// import '../Widgets/action_list.dart';
import '../Widgets/bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F5), // สีพื้นหลังแบบนุ่ม
      body: SafeArea(
        child: Column(
          children: const [
            HeaderSection(),
            // ShortcutButtons(),
            // Expanded(child: SuggestionCarousel()),
            // ActionList(),
            SizedBox(height: 10),
            Text("Home page"),

            //Rive animation Test
            SizedBox(
              width: 100,
              height: 100,
              child: RiveAnimation.asset(
                'assets/animations/test6.riv',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
