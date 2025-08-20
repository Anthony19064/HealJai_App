// screens/article_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String title;
  const ArticleDetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.mali()),
        backgroundColor: const Color(0xFF8FBC8F),
      ),
      body: Center(
        child: Text(
          'เนื้อหาของบทความ "$title"',
          style: GoogleFonts.mali(fontSize: 22),
        ),
      ),
    );
  }
}