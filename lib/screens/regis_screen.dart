// lib/screens/regis_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisScreen extends StatelessWidget {
  const RegisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text(
          'สร้างบัญชี', // Title สำหรับหน้าลงทะเบียน
          style: TextStyle(
            color: Color(0xFF6B8E23),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'นี่คือหน้าสร้างบัญชี',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // เพิ่ม Widgets หม่องนี้
              // เช่น พวกกรอกข้อมูล
              // ปุ่ม "สมัครสมาชิก"
              ElevatedButton(
                onPressed: () {
                  // เมื่อลงทะเบียนสำเร็จ อาจจะกลับไปหน้า Login หรือไปหน้า Home เลย
                  context.go('/login'); // หรือ context.go('/');
                },
                child: const Text('ลงทะเบียน (ตัวอย่าง)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}