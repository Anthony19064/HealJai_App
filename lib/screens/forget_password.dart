import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final PageController _pageController = PageController();

  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();
  final _formKeyCPassword = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

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
            if (_pageController.page == 0) {
              context.pop();
            } else {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn,
              );
            }
          },
        ),
        title: Text(
          'ลืมรหัสผ่านหรอ?',
          style: GoogleFonts.mali(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF78B465),
          ),
        ),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // ขั้นตอนที่ 1: กรอกอีเมล
          _buildStepContent(
            messageTopic: "ไม่เป็นไรนะเรามาตั้งรหัสผ่านใหม่กัน",
            formkey: _formKeyEmail,
            inputController: _emailController,
            hinttext: "อีเมลที่เคยใช้สมัคร",
            labeltext: "Email", // <<-- ส่ง labeltext ที่นี่
            buttonText: 'ส่งรหัสกู้คืน',
            onButtonPressed: () {
              if (_formKeyEmail.currentState!.validate()) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            },
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
          ),
          // ขั้นตอนที่ 2: ตั้งรหัสผ่านใหม่
          _buildStepContent(
            messageTopic: "มาตั้งรหัสผ่านใหม่กัน",
            formkey: _formKeyPassword,
            inputController: _passwordController,
            hinttext: "New Password",
            labeltext: "รหัสผ่านใหม่", // <<-- ส่ง labeltext ที่นี่
            isPassword: true,
            buttonText: 'ถัดไป',
            onButtonPressed: () {
              if (_formKeyPassword.currentState!.validate()) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'กรุณากรอกรหัสผ่านใหม่';
              }
              if (value.length < 8) {
                return 'รหัสผ่านต้องยาวอย่างน้อย 8 ตัวนะ :)';
              }
              return null;
            },
          ),
          // ขั้นตอนที่ 3: ยืนยันรหัสผ่านใหม่
          _buildStepContent(
            messageTopic: "ยืนยันรหัสผ่านใหม่เพื่อความแน่ใจ",
            formkey: _formKeyCPassword,
            inputController: _confirmPasswordController,
            hinttext: "Confirm New Password",
            labeltext: "ยืนยันรหัสผ่านใหม่", // <<-- ส่ง labeltext ที่นี่
            isPassword: true,
            buttonText: 'ยืนยันรหัสผ่าน',
            onButtonPressed: () {
              if (_formKeyCPassword.currentState!.validate()) {
                print('Email: ${_emailController.text}');
                print('New Password: ${_passwordController.text}');
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'กรุณายืนยันรหัสผ่านใหม่';
              }
              if (value.length < 8) {
                return 'รหัสผ่านต้องยาวอย่างน้อย 8 ตัวนะ :)';
              }
              if (_passwordController.text != _confirmPasswordController.text) {
                return 'รหัสผ่านไม่ตรงกัน';
              }
              return null;
            },
          ),
          // ขั้นตอนที่ 4: เสร็จสิ้น
          _buildStepContent(
            messageTopic: "เยี่ยมเลย\nรหัสผ่านของเธอถูกเปลี่ยนเรียบร้อยแล้ว!",
            formkey: null,
            inputController: null,
            hinttext: "",
            buttonText: 'กลับสู่หน้าเข้าสู่ระบบ',
            onButtonPressed: () {
              context.go('/login');
            },
            isEnd: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent({
    bool isEnd = false,
    required String messageTopic,
    required GlobalKey? formkey,
    required TextEditingController? inputController,
    FormFieldValidator<String>? validator,
    required String hinttext,
    String? labeltext,
    required String buttonText,
    required VoidCallback onButtonPressed,
    bool isPassword = false,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 20.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
             
              child: Text(
                messageTopic,
                style: GoogleFonts.mali(
                  fontSize: 16,
                  height: 2.0,
                  color: const Color(0xFF464646),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Container(
          //   margin: const EdgeInsets.only(top: 40.0),
          //   child: Lottie.asset(
          //     'assets/animations/runing.json',
          //     height: 200,
          //     fit: BoxFit.contain,
          //     errorBuilder: (context, error, stackTrace) {
          //       return const Icon(
          //         Icons.image_not_supported,
          //         size: 100,
          //         color: Colors.grey,
          //       );
          //     },
          //   ),
          // ),
          
          if (!isEnd) ...[
            // **ส่วนที่แก้ไข: เพิ่ม Text Widget สำหรับ Label เหนือ Form**
            if (labeltext != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 20.0, bottom: 8.0),
                  child: Text(
                    labeltext,
                    style: GoogleFonts.mali(
                      color: Color(0xFF78B465),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Container(
              child: Form(
                key: formkey,
                child: TextFormField(
                  controller: inputController,
                  validator: validator,
                  obscureText: isPassword,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._\-]')),
                  ],
                  decoration: InputDecoration(
                    hintText: hinttext,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                  ),
                  style: GoogleFonts.mali(fontSize: 16),
                ),
              ),
            ),
          ],
          
          Container(
            margin: const EdgeInsets.only(top: 30.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF78B465),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.mali(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Container(height: 40, margin: const EdgeInsets.only(bottom: 0.0)),
        ],
      ),
    );
  }
}