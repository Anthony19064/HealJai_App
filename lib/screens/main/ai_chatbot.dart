import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({super.key});

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  
  @override
  void initState() {
    super.initState();
    // สั่งให้เปิดแถบแชท (Modal Bottom Sheet) ขึ้นมาทันทีเมื่อเข้าหน้าจอ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openChatSheet();
    });
  }

  void _openChatSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // ทำให้พื้นหลัง Modal โปร่งใสเพื่อความมนของขอบ
      barrierColor: Colors.transparent,     // พื้นหลังจอไม่มืด เพื่อให้เห็นแอนิเมชันด้านหลัง
      enableDrag: true,
      builder: (context) {
        return _buildChatSheetContent();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ขยายพื้นที่ body ให้ไปอยู่หลัง AppBar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'น้องฮีลใจ',
          style: GoogleFonts.kanit(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. พื้นหลังวิวธรรมชาติ
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB3E5FC), Colors.white],
              ),
            ),
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/app_bg.png', 
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // 2. โลโก้ตัวละครตรงกลางพร้อม Pulse Effect
          Align(
            alignment: const Alignment(0, -0.4),
            child: Pulse(
              infinite: true,
              duration: const Duration(seconds: 2),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/icons/app_icon.png'), // รูปน้องห่าน
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. ส่วนเนื้อหาแชทภายใน Modal
  Widget _buildChatSheetContent() {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF8EE), // สีครีมตามแบบ UI
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 15),
            ],
          ),
          child: Column(
            children: [
              // ขีดสำหรับลากด้านบน
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 55,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCDE1F9),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              // รายการข้อความ
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _bubbleLeft("สวัสดีเพื่อน"),
                    _bubbleRight("เราอยากได้กำลังใจ"),
                    _bubbleLeft("..."), // จำลองสถานะพิมพ์
                  ],
                ),
              ),
              
              // ช่องพิมพ์ข้อความ
              _buildInputBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _bubbleLeft(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage('assets/icons/app_icon.png'),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F1D7),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(text, style: GoogleFonts.kanit(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _bubbleRight(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF82B96D),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              text,
              style: GoogleFonts.kanit(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'พิมพ์ข้อความที่นี่ . . . .',
          hintStyle: GoogleFonts.kanit(color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.send_rounded, color: Colors.black87),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),
    );
  }
}