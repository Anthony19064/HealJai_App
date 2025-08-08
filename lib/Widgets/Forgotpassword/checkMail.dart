import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:healjai_project/service/forgotPassword.dart';
import 'package:healjai_project/providers/ResetProvider.dart';

class CheckEmail extends StatefulWidget {
  final PageController pageController;

  const CheckEmail({super.key, required this.pageController});

  @override
  State<CheckEmail> createState() => _CheckEmailState();
}

class _CheckEmailState extends State<CheckEmail> {
  final TextEditingController _emailController = TextEditingController();
  final _formKeyEmail = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final ResetInfo = Provider.of<ResetProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ZoomIn(
        duration: Duration(milliseconds: 500),
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
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.25,
              child: Lottie.asset("assets/animations/cry.json"),
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
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
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
              height: 50,
              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : () async {
                          if (_formKeyEmail.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            final data = await checkMail(_emailController.text);

                            if (data['success']) {
                              ResetInfo.setMail(_emailController.text);
                              final status = await send_OTP(
                                _emailController.text,
                              );
                              if (status['success']) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 2),
                                    content: Text(
                                      status['message'],
                                      style: GoogleFonts.mali(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    backgroundColor: Color(0xFF78B465),
                                  ),
                                );
                                setState(() {
                                  isLoading = false;
                                });
                                await Future.delayed(Duration(seconds: 2));
                                widget.pageController.nextPage(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                );
                              }
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: Duration(seconds: 2),
                                  content: Text(
                                    data['message'],
                                    style: GoogleFonts.mali(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: Color(0xFFFD7D7E),
                                ),
                              );
                            }
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF78B465),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child:
                    isLoading
                        ? Lottie.asset('assets/animations/loading.json')
                        : Text(
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
      ),
    );
  }
}
