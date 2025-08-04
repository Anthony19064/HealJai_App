import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckEmail extends StatefulWidget {
  final PageController pageController;

  const CheckEmail({super.key, required this.pageController});

  @override
  State<CheckEmail> createState() => _CheckEmailState();
}

class _CheckEmailState extends State<CheckEmail> {
  final TextEditingController _emailController = TextEditingController();
  final _formKeyEmail = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: [
          SizedBox(height: 30),
          Text(
            "เธอลืมรหัสผ่านหรอ ?",
            style: GoogleFonts.mali(
              color: Color(0xFF78B465),
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 25),
          Text(
            "ไม่เป็นไรนะ เรามาเปลี่ยนรหัสผ่านกัน",
            style: GoogleFonts.mali(
              color: Color(0xFF464646),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 50),
          Container(
            width: double.infinity,
            child: Text(
              "Email",
              style: GoogleFonts.mali(
                color: Color(0xFF78B465),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 10),
          Form(
            key: _formKeyEmail,
            child: TextFormField(
              controller: _emailController,
              validator: (value) {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกอีเมล';
                }
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'รูปแบบอีเมลไม่ถูกต้อง';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: "Email ที่เคยใช้สมัคร",
                hintStyle: GoogleFonts.mali(
                  color: Color(0xFFA7A7A7),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide(color: Color(0xFFB3B3B3), width: 2),
                ),
                fillColor: Colors.white, // สีพื้นหลัง
                filled: true,
              ),
            ),
          ),
          SizedBox(height: 30),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKeyEmail.currentState!.validate()) {
                  widget.pageController.nextPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF78B465),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                "ส่งรหัสยืนยัน",
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
    );
  }
}
