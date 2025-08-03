import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final PageController _pageController = PageController();

  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyOtp = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();

  
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    
    _pages = [
      _buildStepContent(
        messageTopic: "เธอลืมรหัสผ่านเหรอ?",
        messageSubTopic: "ไม่เป็นไรนะเรามาเปลี่ยนรหัสผ่านกัน",
        formkey: _formKeyEmail,
        inputController: _emailController,
        hinttext: "อีเมลที่เคยใช้สมัคร",
        labeltext: "Email",
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
      
      // **ขั้นตอนที่ 2: กรอกรหัส OTP 
      _buildStepContent(
        messageTopic: "เธอได้รหัสยืนยันไหม ?", // <<--- ข้อความใหม่
        messageSubTopic: "เอารหัส 6 หลักที่ได้มากรอกด้านล่างได้เลยนะ", // <<--- เพิ่มข้อความย่อย
        formkey: _formKeyOtp,
        inputController: _otpController,
        hinttext: "กรุณากรอกรหัส",
        labeltext: "", 
        buttonText: 'ถัดไป', 
        isOtp: true,
        showResendButton: true,
        onResendPressed: () {
          print('Resend OTP button pressed!');
          // TODO: ใส่ Logic สำหรับส่งรหัส OTP ใหม่
        },
        onButtonPressed: () {
          if (_formKeyOtp.currentState!.validate()) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        },
        validator: (value) {
          if (value == null || value.length < 6) {
            return 'กรุณากรอกรหัส 6 หลักให้ครบถ้วน';
          }
          return null;
        },
      ),
      
      // **ขั้นตอนที่ 3: กรอก pass ใหม่
      _buildStepContent(
        messageTopic: "มาสร้างรหัสผ่านใหม่กัน",
        messageSubTopic: "ขอแบบยากๆเลยนะ แต่เอาแบบที่เธอจำได้นะ",
        formkey: _formKeyPassword,
        inputController: _passwordController,
        hinttext: "New Password",
        labeltext: "New Password",
        isPassword: true,
        confirmInputController: _confirmPasswordController,
        confirmPasswordValidator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'กรุณายืนยันรหัสผ่านใหม่';
          }
          if (value != _passwordController.text) {
            return 'รหัสผ่านไม่ตรงกัน';
          }
          return null;
        },
        buttonText: 'รีเซ็ตรหัสผ่าน',
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

      // **ขั้นตอนที่ 4: เสร็จสิ้น
      _buildStepContent(
        messageTopic: "เสร็จแล้ว",
        messageSubTopic: "ตั้งรหัสผ่านใหม่เรียบร้อยแล้ว login ได้เลยนะ",
        formkey: null,
        inputController: null,
        hinttext: "",
        buttonText: 'กลับสู่หน้าเข้าสู่ระบบ',
        onButtonPressed: () {
          context.go('/login');
        },
        isEnd: true,
      ),
    ];
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
            if (_pageController.hasClients && _pageController.page?.round() == 0) {
              context.pop();
            } else {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn,
              );
            }
          },
        ),
        
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
    );
  }

  Widget _buildStepContent({
    bool isEnd = false,
    bool isOtp = false,
    required String messageTopic,
    String? messageSubTopic, // <<--- เพิ่ม parameter ใหม่สำหรับข้อความย่อย
    GlobalKey? formkey,
    TextEditingController? inputController,
    FormFieldValidator<String>? validator,
    required String hinttext,
    String? labeltext,
    required String buttonText,
    required VoidCallback onButtonPressed,
    bool isPassword = false,
    bool showResendButton = false, // <<--- เพิ่ม parameter ใหม่
    VoidCallback? onResendPressed, // <<--- เพิ่ม parameter ใหม่
    TextEditingController? confirmInputController,
    FormFieldValidator<String>? confirmPasswordValidator,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // **แก้ไขส่วนแสดงข้อความ**
          Container(
            margin: const EdgeInsets.only(top: 20.0),
            child: Text( // <<--- ใช้ Text Widget ธรรมดาตามภาพ
              messageTopic,
              style: GoogleFonts.mali(
                fontSize: 22, // <<--- ปรับขนาดให้ใหญ่ขึ้น
                fontWeight: FontWeight.bold,
                color: const Color(0xFF78B465),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (messageSubTopic != null) // **<<--- แสดงข้อความย่อยถ้ามี**
            Container(
              margin: const EdgeInsets.only(top: 10.0),
              child: Text(
                messageSubTopic,
                style: GoogleFonts.mali(
                  fontSize: 16,
                  color: const Color(0xFF464646),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
        
          
          if (!isEnd) ...[
            if (labeltext != null && !isOtp) 
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 20.0, bottom: 8.0),
                  child: Text(
                    labeltext,
                    style: GoogleFonts.mali(
                      color: const Color(0xFF78B465),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            Container(
              margin: EdgeInsets.only(top: isOtp ? 40.0 : 0.0), 
              child: Form(
                key: formkey,
                child: Column(
                  children: [
                    if (isOtp)
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: inputController,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10),
                          fieldHeight: 50,
                          fieldWidth: 45,
                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          selectedFillColor: Colors.white,
                          activeColor: const Color(0xFF78B465),
                          inactiveColor: Colors.grey.shade300,
                          selectedColor: const Color(0xFF78B465),
                        ),
                        backgroundColor: Colors.transparent,
                        animationType: AnimationType.fade,
                        keyboardType: TextInputType.number,
                        textStyle: GoogleFonts.mali(fontSize: 18),
                        validator: validator,
                        onChanged: (value) {},
                      )
                    else
                      TextFormField(
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
                    
                    if (isPassword) ...[
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0.0, top: 0.0, bottom: 8.0),
                          child: Text(
                            'Comfirm New Password',
                            style: GoogleFonts.mali(
                              color: const Color(0xFF78B465),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: confirmInputController,
                        validator: confirmPasswordValidator,
                        obscureText: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._\-]')),
                        ],
                        decoration: InputDecoration(
                          hintText: "Confirm New Password",
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
                    ],
                  ],
                ),
              ),
            ),
          ],
          
          if (!isOtp) // **<<--- ซ่อนปุ่มส่งรหัสอีกครั้งถ้าไม่ใช่หน้า OTP**
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
          
          if (isOtp) // **<<--- แสดงปุ่ม "ถัดไป" และปุ่มส่งรหัสอีกครั้ง**
            Column(
              children: [
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
                if (showResendButton && onResendPressed != null)
                  Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child: TextButton(
                      onPressed: onResendPressed,
                      child: Text(
                        'ไม่ได้รหัสยืนยันหรอ? ส่งรหัสยืนยันอีกครั้ง',
                        style: GoogleFonts.mali(
                          color: Colors.grey,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
          Container(height: 40, margin: const EdgeInsets.only(bottom: 0.0)),
        ],
      ),
    );
  }
}