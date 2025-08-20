import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/providers/chatProvider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

class CustomExitDialog extends StatelessWidget {
  final String animationRole;
  final Color primaryColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CustomExitDialog({
    super.key,
    required this.animationRole,
    required this.primaryColor,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(color: primaryColor.withOpacity(0.8), width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: RiveAnimation.asset(
                'assets/animations/rives/leave_chat.riv',
                animations: [animationRole],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'จะไปแล้วหรอ',
              style: GoogleFonts.mali(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF464646),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'บอกลาคู่สนทนาของเธอแล้วใช่มั้ย ?',
              textAlign: TextAlign.center,
              style: GoogleFonts.mali(
                fontSize: 14,
                color: Color(0xFF464646),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                elevation: 2,
                shadowColor: primaryColor.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Container(
                width: double.infinity,
                child: Text(
                  'จบบทสนทนา',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mali(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: primaryColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Container(
                width: double.infinity,
                child: Text(
                  'ยกเลิก',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mali(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
