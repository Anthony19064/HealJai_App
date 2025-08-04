import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import 'package:healjai_project/service/forgotPassword.dart';
import 'package:healjai_project/providers/ResetProvider.dart';

class CheckOTP extends StatefulWidget {
  final PageController pageController;
  const CheckOTP({super.key, required this.pageController});

  @override
  State<CheckOTP> createState() => _CheckOTPState();
}

class _CheckOTPState extends State<CheckOTP> {
  final TextEditingController _OTPController = TextEditingController();
  final _formKeyOTP = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final resetProvider = Provider.of<ResetInfo>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ZoomIn(
        duration: Duration(milliseconds: 500),
        child: Column(
          children: [
            SizedBox(height: 30),
            Text(
              "เธอได้รหัสยืนยันมั้ย ?",
              style: GoogleFonts.mali(
                color: Color(0xFF78B465),
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 25),
            Text(
              "เอารหัส 6 หลักที่ได้มากรอกด้านล่างนี้ได้เลยนะ",
              style: GoogleFonts.mali(
                color: Color(0xFF464646),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 50),
            Form(
              key: _formKeyOTP,
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _OTPController,
                animationDuration: Duration(milliseconds: 200),
                backgroundColor: Colors.transparent,
                enableActiveFill: true,
                animationType: AnimationType.scale,
                keyboardType: TextInputType.number,
                textStyle: GoogleFonts.mali(
                  fontSize: 35,
                  color: Color(0xFF464646),
                ),
        
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 70,
                  fieldWidth: 50,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  activeColor: const Color(0xFF78B465),
                  inactiveColor: Colors.grey.shade300,
                  selectedColor: const Color(0xFF78B465),
                ),
        
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'กรุณากรอกรหัสให้ครบถ้วน';
                  }
                  return null;
                },
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
                          if (_formKeyOTP.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            final data = await verify_OTP(
                              resetProvider.mail,
                              _OTPController.text,
                            );
                            if (data['success']) {
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
                          "ยืนยัน",
                          style: GoogleFonts.mali(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "ไม่ได้รหัสยืนยันหรอ?",
                  style: GoogleFonts.mali(
                    color: Color(0xFF464646),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    final data = await send_OTP(resetProvider.mail);
                    if (data['success']) {
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
                          backgroundColor: Color(0xFF78B465),
                        ),
                      );
                    }
                    setState(() {
                      isLoading = false;
                    });
                  },
                  child: Text(
                    "ส่งรหัสยืนยันอีกครั้ง",
                    style: GoogleFonts.mali(
                      color: Color(0xFF78B465),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
