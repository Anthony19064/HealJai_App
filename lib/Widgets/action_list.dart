import 'package:flutter/material.dart';

class ActionList extends StatelessWidget {
  const ActionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ActionCard(
          icon: Icons.edit_note,
          title: 'ไดอารี่บันทึกเรื่องราวดี ๆ',
          subtitle: 'มาเก็บประสบการณ์ดีๆ ประจำวันกันเถอะ !!',
        ),
        ActionCard(
          icon: Icons.mail,
          title: 'ส่งข้อความถึงตัวเองในอนาคต',
          subtitle: 'เขียนไว้เพื่อย้ำเตือนตัวเองในอนาคต ✨',
        ),
      ],
    );
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ActionCard({required this.icon, required this.title, required this.subtitle, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Color.fromARGB(255, 79, 138, 65)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
