
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';



class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
            context.go('/');
          },
        ),
        title: const Text(
          'HealJai',
          style: TextStyle(
            color: Color(0xFF6B8E23), // สี heal jai
            fontSize: 24,
            fontWeight: FontWeight.bold,
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
                  fit: BoxFit.cover, // ทำให้รูปครอบคลุมพื้นที่วงกลม
                ),
              ),
            ),
            const SizedBox(height: 40),

            // **CustomInputField สำหรับ username 
            _buildInputField(
              labelText: 'username',
            ),
            const SizedBox(height: 20),
            // **CustomInputField สำหรับ password 
            _buildInputField(
              labelText: 'password',
              isPassword: true,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // ฟังชั่นปุ่ม forgot password
                },
                child: const Text(
                  'ลืมรหัสผ่าน ?',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildLoginButton(context),
            const SizedBox(height: 20),
            _buildSignUpRow(context),
            const SizedBox(height: 30),
            const Text(
              'หรือ',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            // **SocialLoginButton Google 
            _buildSocialLoginButton(
              iconPath: 'assets/images/google.png', // ไอค่อน google
              text: 'ล็อกอินด้วย Google',
              onPressed: () {
                // ฟังชั่นปุ่ม login google
              },
            ),
            const SizedBox(height: 15),
            // **SocialLoginButton Facebook 
            _buildSocialLoginButton(
              iconPath: 'assets/images/facebook.png', // ไอค่อน Facebook
              text: 'ล็อกอินด้วย Facebook',
              onPressed: () {
                // ฟังชั่นปุ่ม login facebook
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // **ส่วนโค้ดของ CustomInputField ถูกย้ายมาเป็น private method**
  Widget _buildInputField({
    required String labelText,
    String hintText = '',
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none, // No border color
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          ),
        ),
      ],
    );
  }

  // ส่วนโค้ด _buildLoginButton (เหมือนเดิม)
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

  // ส่วนโค้ด _buildSignUpRow 
  Widget _buildSignUpRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'ยังไม่มีบัญชีหรือ',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16,
          ),
        ),
        TextButton(
          onPressed: () {
            context.go('/regis'); // ไปหน้า regis
          },
          child: const Text(
            'สร้างบัญชี',
            style: TextStyle(
              color: Color(0xFF6B8E23),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // **ส่วนโค้ดของ SocialLoginButton 
  Widget _buildSocialLoginButton(
      {required String iconPath, required String text, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 24,
              height: 24,
              child: Image.asset(iconPath),
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}