import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

List<String> badwordLst = [
  // คำหยาบแรง ๆ
  "ควย",
  "kuy",
  "ครวย"
  "เหี้ย",
  "หี",
  "สัส",
  "ไอ้สัตว์",
  "เย็ด",
  "เงี่ยน",
  "ส้นตีน",
  "แม่ง",
  "ไอ้ควาย",
  "ไอ้เวร",
  "ดอกทอง"
  // คำด่าเกี่ยวกับครอบครัว
  "พ่อมึงตาย",
  "แม่มึงตาย",
  "พ่อมึง",
  "แม่มึง",
  // คำหยาบเบา ๆ แต่ใช้ด่า
  "กู",
  "มึง",
  "โง่",
  "ปัญญาอ่อน",
  "สถุน",
  "เลว",
  "ชั่ว",
  "ขยะ",
  "สวะ",
  "ไอ้จน",
  // คำเหยียด/กึ่งหยาบ
  "ลาว",
  "ควาย",
  "ไอ้ชาติหมา",
  "กาก",
  "เลวระยำ",
  "กระหรี่",
  "กะหรี่",
  // คำกึ่งทะลึ่ง
  "นม",
  "ตูด",
  "เย็ด",
  "ขี้เย็ด",
  "แตกใน",
  "กระโปก",
];

bool checkBadWord(String textInput) {
  return badwordLst.any((word) => textInput.contains(word));
}

void showErrorToast() {
  toastification.show(
    type: ToastificationType.error,
    style: ToastificationStyle.flat,
    icon: const Icon(
      Icons.sentiment_dissatisfied_rounded,
      color: Colors.red,
      size: 28, 
    ),
    title: Text(
      "พบคำไม่เหมาะสม",
      style: GoogleFonts.mali(
        color: Color(0xFF464646),
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    ),
    description: Text(
      "โปรดใช้คำสุภาพในการพูดคุย",
      style: GoogleFonts.mali(
        color: Color(0xFF464646),
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    alignment: Alignment.topCenter,
    borderRadius: BorderRadius.circular(15),
    autoCloseDuration: const Duration(seconds: 2),
    showProgressBar: false,
    animationDuration: const Duration(milliseconds: 500),
    animationBuilder: (context, animation, alignment, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut, // แบบเด้ง
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1), // เริ่มจากบน
          end: Offset.zero, // ลงมาที่ปกติ
        ).animate(curved),
        child: child,
      );
    },
  );
}
