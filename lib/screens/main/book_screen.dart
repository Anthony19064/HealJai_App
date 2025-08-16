import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart'; // 1. เพิ่ม import สำหรับ go_router

class BookScreen extends StatelessWidget {
  const BookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB), // สีพื้นหลัง
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'บทความ',
          style: GoogleFonts.mali(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF78B465), // สีเขียวอ่อน
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: const [
            _BookCard(
              title: 'ความสุข',
              imagePath: 'assets/images/wagu1.jpg',
            ),
            _BookCard(
              title: 'ความรัก',
              imagePath: 'assets/images/wagu2.jpg',
            ),
            _BookCard(
              title: 'กำลังใจ',
              imagePath: 'assets/images/wagu3.jpg',
            ),
            _BookCard(
              title: 'แบ่งปัน',
              imagePath: 'assets/images/wagu4.jpg',
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final String title;
  final String imagePath;

  const _BookCard({required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15), // ทำให้ ripple effect โค้งตาม
        onTap: () {
          // 2. แก้ไข onTap ให้ใช้ context.push เพื่อไปยังหน้ารายละเอียด
          context.push('/book/$title');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: Colors.grey, size: 50));
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.mali(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}