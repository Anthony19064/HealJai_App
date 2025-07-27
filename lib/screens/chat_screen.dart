import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ZoomIn(
          duration: Duration(milliseconds: 500),
          child: Text('Chat Page')),
      ],
    );
  }
}