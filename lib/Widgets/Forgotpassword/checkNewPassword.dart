import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/service/forgotPassword.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:healjai_project/providers/ResetProvider.dart';

class NewPassword extends StatefulWidget {
  final PageController pageController;
  const NewPassword({super.key, required this.pageController});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _CPasswordController = TextEditingController();
  final _formKeyPassword = GlobalKey<FormState>();
  bool isLoading = false;
  bool _passwordState = true;
  bool _CpasswordState = true;

  @override
  Widget build(BuildContext context) {
    final resetInfo = Provider.of<ResetProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ZoomIn(
        duration: Duration(milliseconds: 500),
        child: Column(
          children: [
            SizedBox(height: 30),
            Text(
              "มาสร้างรหัสผ่านใหม่กัน !!",
              style: GoogleFonts.mali(
                color: Color(0xFF78B465),
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 25),
            Text(
              "ขอแบบยากๆเลยนะ แต่เอาแบบที่เธอจำได้นะ",
              style: GoogleFonts.mali(
                color: Color(0xFF464646),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 50),
            Form(
              key: _formKeyPassword,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: Text(
                      "New Password",
                      style: GoogleFonts.mali(
                        color: Color(0xFF78B465),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    style: GoogleFonts.mali(
                      fontSize: 17,
                      color: Color(0xFF464646),
                      fontWeight: FontWeight.w700,
                    ),
                    controller: _passwordController,
                    obscureText: _passwordState,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอกรหัสผ่านใหม่';
                      }
                      if (value.length < 8) {
                        return 'รหัสผ่านต้องยาวอย่างน้อย 8 ตัวนะ :)';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "รหัสผ่านใหม่",
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
                        borderSide: BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(
                          color: Color(0xFFB3B3B3),
                          width: 2,
                        ),
                      ),
                      fillColor: Colors.white, // สีพื้นหลัง
                      filled: true,

                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordState
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Color(0xFF5C5C5C),
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordState = !_passwordState;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    child: Text(
                      "Confirm New Password",
                      style: GoogleFonts.mali(
                        color: Color(0xFF78B465),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    style: GoogleFonts.mali(
                      fontSize: 17,
                      color: Color(0xFF464646),
                      fontWeight: FontWeight.w700,
                    ),
                    controller: _CPasswordController,
                    obscureText: _CpasswordState,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณายืนยันรหัสผ่านใหม่';
                      }
                      if (value != _passwordController.text) {
                        return 'รหัสผ่านไม่ตรงกัน';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "ยืนยันรหัสผ่าน",
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
                        borderSide: BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(
                          color: Color(0xFFB3B3B3),
                          width: 2,
                        ),
                      ),
                      fillColor: Colors.white, // สีพื้นหลัง
                      filled: true,

                      suffixIcon: IconButton(
                        icon: Icon(
                          _CpasswordState
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Color(0xFF5C5C5C),
                        ),
                        onPressed: () {
                          setState(() {
                            _CpasswordState = !_CpasswordState;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : () async {
                          if (_formKeyPassword.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            final data = await reset_Password(
                              resetInfo.mail,
                              _passwordController.text,
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
                              setState(() {
                                isLoading = false;
                              });
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
          ],
        ),
      ),
    );
  }
}
