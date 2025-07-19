import 'package:flutter/material.dart';

import '../Widgets/header_section.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB),
      body: SafeArea(
        child: Column(
          children: [
            HeaderSection(),
            Text('Chat Page'),
          ],
        )),
    );
  }
}