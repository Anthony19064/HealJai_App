import 'package:flutter/material.dart';
import '../Widgets/header_section.dart';
import '../Widgets/shortcut_buttons.dart';
import '../Widgets/suggestion_carousel.dart';
import '../Widgets/action_list.dart';
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
            // HeaderSection(),
            // ShortcutButtons(),
            // Expanded(child: SuggestionCarousel()),
            // ActionList(),
            SizedBox(height: 10),
          ],
        ),
      ),

      // ✅ ปุ่มลอยตรงกลาง
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 30),
        child: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.white,
        shape: const CircleBorder(
          side: BorderSide(
            color: Color.fromARGB(255, 79, 138, 65),
            width: 5.0,
          )
        ), 
        elevation: 10,
        child: const Icon(Icons.chat, color: Color.fromARGB(255, 79, 138, 65)), // เขียว

      ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

     
      bottomNavigationBar: const BottomNavBar(),
    );
    
  }
}
