import 'package:flutter/material.dart';
import '../Widgets/header_section.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB),
      body: SafeArea(
        child:Column(
          children: [
            HeaderSection(),
            Text("BookPage")
          ],
        )),
    );
  }
}