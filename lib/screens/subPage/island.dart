import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healjai_project/Widgets/bottom_nav.dart'; // Assuming you have this file

class Island extends StatelessWidget {
  const Island({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(),
      appBar: AppBar(
        title: const Text('My Island'),
        backgroundColor: const Color(0xFF2A4758),
        elevation: 0,
        foregroundColor: Colors.white, // For the back arrow
        automaticallyImplyLeading: false, // Hide the default back button
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
            // This is the new button
            ElevatedButton.icon(
              onPressed: () {
                // Navigate back to the game screen
                context.go('/game');
              },
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
}
