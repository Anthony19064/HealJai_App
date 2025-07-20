import 'package:flutter/material.dart';
import '../Widgets/custom_input_field.dart'; // Import custom widgets
import '../Widgets/social_login_button.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // Light peach background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
             context.go('/');
          },
        ),
        title: const Text(
          'HealJai',
          style: TextStyle(
            color: Color(0xFF6B8E23), // HealJai green color
            fontSize: 24,
            fontWeight: FontWeight.bold,
            // fontFamily: 'Mitr', // ถ้าตั้งใน ThemeData แล้ว ไม่ต้องตั้งซ้ำที่นี่
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            // รูปโลโก้
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, 
                border: Border.all(color: Colors.grey.shade300, width: 1),
                image: const DecorationImage(
                  image: AssetImage('assets/images/duck.png'), // path รูปโลโก้
                ),
              ),
            ),
            const SizedBox(height: 40),
            CustomInputField(
              labelText: 'username',
            ),
            const SizedBox(height: 20),
            CustomInputField(
              labelText: 'password',
              isPassword: true,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Handle forgot password
                },
                child: const Text(
                  'ลืมรหัสผ่าน ?', // Forgot password?
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildLoginButton(context), // ยังคงเป็น private method ใน LoginScreen เพราะมันเฉพาะเจาะจงกับหน้านี้
            const SizedBox(height: 20),
            _buildSignUpRow(context), // ยังคงเป็น private method ใน LoginScreen
            const SizedBox(height: 30),
            const Text(
              'หรือ', // Or
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            SocialLoginButton(
              iconPath: 'assets/images/google.png', // ไอค่อน google
              text: 'ล็อกอินด้วย Google',
              onPressed: () {
                // Handle Google login
              },
            ),
            const SizedBox(height: 15),
            SocialLoginButton(
              iconPath: 'assets/images/facebook.png', // ไอค่อน Facebook 
              text: 'ล็อกอินด้วย Facebook',
              onPressed: () {
                // ควบคุมกดปุ่มล็อกอิน
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // แยกเป็น private method ภายใน LoginScreen เพราะใช้แค่ในหน้านี้
  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // Handle login logic
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA5D6A7), // Green button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Log in',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // แยกเป็น private method ภายใน LoginScreen เพราะใช้แค่ในหน้านี้
  Widget _buildSignUpRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'ยังไม่มีบัญชีหรือ', // Don't have an account yet or
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16,
          ),
        ),
        TextButton(
          onPressed: () {
            context.go('/regis');
          },
          child: const Text(
            'สร้างบัญชี', // Create account
            style: TextStyle(
              color: Color(0xFF6B8E23), // HealJai green color
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}