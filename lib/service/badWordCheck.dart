import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

List<String> badwordLst = [
  // คำหยาบแรง ๆ
  "ควย",
  "เหี้ย",
  "หี",
  "สัส",
  "ไอ้สัตว์",
  "สัส",
  "เย็ด",
  "เงี่ยน",
  "ส้นตีน",
  "แม่ง",
  "ไอ้ควาย",
  "ไอ้เวร",
  // คำด่าเกี่ยวกับครอบครัว
  "พ่อมึงตาย",
  "แม่มึงตาย",
  "พ่อมึง",
  "แม่มึง",
  // คำหยาบเบา ๆ แต่ใช้ด่า
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
  "สถุน",
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

void showErrorSnackBar(BuildContext context) {
  final snackBar = SnackBar(
    content: Text(
      "มีคำไม่เหมาะสม",
      style: GoogleFonts.mali(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16),
      textAlign: TextAlign.center,
    ),
    backgroundColor: Color(0xFFFD7D7E),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
