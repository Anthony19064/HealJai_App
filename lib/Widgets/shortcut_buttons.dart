import 'package:flutter/material.dart';

class ShortcutButtons extends StatelessWidget {
  const ShortcutButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.favorite, 'label': 'บันทึกความดี'},
      {'icon': Icons.card_giftcard, 'label': 'เก็บแต้ม'},
      {'icon': Icons.notifications, 'label': 'แจ้งเตือน'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          return Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 28,
                child: Icon(item['icon'] as IconData, size: 28, color: Color.fromARGB(255, 79, 138, 65)),
              ),
              const SizedBox(height: 6),
              Text(item['label'] as String),
            ],
          );
        }).toList(),
      ),
    );
  }
}
