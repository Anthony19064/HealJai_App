import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:healjai_project/Widgets/Forgotpassword/checkMail.dart';
import 'package:healjai_project/Widgets/Forgotpassword/checkOTP.dart';
import 'package:healjai_project/Widgets/Forgotpassword/checkNewPassword.dart';
import 'package:healjai_project/Widgets/Forgotpassword/Success.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final PageController _pageController = PageController();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      CheckEmail(pageController: _pageController), //หน้าแรกถาม Email
      CheckOTP(pageController: _pageController), //หน้ายืนยัน OTP
      NewPassword(pageController: _pageController), //หน้าเปลี่ยนรหัสผ่าน
      SuccessReset(),
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
            context.go('/login');
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
}
