import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ZoomIn(
          duration: Duration(milliseconds: 500),
          child: Text("BookPage"))
      ],
    );
  }
}