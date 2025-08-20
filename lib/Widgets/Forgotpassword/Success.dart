import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SuccessReset extends StatefulWidget {
  const SuccessReset({super.key});

  @override
  State<SuccessReset> createState() => _SuccessResetState();
}

class _SuccessResetState extends State<SuccessReset> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ZoomIn(
        duration: Duration(milliseconds: 500),
        child: Column(
          children: [
            SizedBox(height: 20),
            SizedBox(
              width: 300,
              height: 300,
              child: Lottie.asset('assets/animations/lotties/congrat.json'),
            ),
            SizedBox(height: 50),
            Text(
              "เย้! รีเซ็ตรหัสผ่านสำเร็จแล้ว 💚",
              textAlign: TextAlign.center,
              style: GoogleFonts.mali(
                color: Color(0xFF78B465),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
        
            SizedBox(height: 20),
            Text(
              "เข้าสู่ระบบด้วยรหัสใหม่กันเลยย ✨",
              style: GoogleFonts.mali(
                color: Color(0xFF464646),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 70),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF78B465),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  "ไปกันเลยย",
                  style: GoogleFonts.mali(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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
