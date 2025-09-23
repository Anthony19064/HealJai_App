import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

void showSuccessToast(String title, String info) {
  toastification.show(
    type: ToastificationType.success,
    style: ToastificationStyle.flat,
    icon: const Icon(
      Icons.sentiment_satisfied_alt_rounded,
      color: Colors.green,
      size: 28, 
    ),
    title: Text(
      title,
      style: GoogleFonts.mali(
        color: Color(0xFF464646),
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    ),
    description: Text(
      info,
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


void showWarningToast(String title, String info) {
  toastification.show(
    type: ToastificationType.warning,
    style: ToastificationStyle.flat,
    icon: const Icon(
      Icons.sentiment_neutral_rounded,
      color: Colors.orange,
      size: 28, 
    ),
    title: Text(
      title,
      style: GoogleFonts.mali(
        color: Color(0xFF464646),
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    ),
    description: Text(
      info,
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