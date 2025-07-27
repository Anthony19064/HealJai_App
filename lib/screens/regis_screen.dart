import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisScreenPageView extends StatefulWidget {
  const RegisScreenPageView({super.key});

  @override
  State<RegisScreenPageView> createState() => _RegisScreenPageViewState();
}

class _RegisScreenPageViewState extends State<RegisScreenPageView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final PageController _pageController = PageController();

  final _formKeyUsername = GlobalKey<FormState>(); // key ของ FormUsername
  final _formKeyEmail = GlobalKey<FormState>(); // key ของ FormEmail
  final _formKeyPassword = GlobalKey<FormState>(); // key ของ FormPassword
  final _formKeyCPassword = GlobalKey<FormState>(); // key ของ FormCPassword

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
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
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // ปิดการปัดด้วยนิ้ว
        onPageChanged: (index) {},
        children: [
          _buildStepContent(
            messageTopic: "ฮัลโหลล ~\nชื่อของเธอคืออะไรหรอ ?",
            formkey: _formKeyUsername,
            inputController: _usernameController,
            hinttext: "Username",
            buttonText: 'ถัดไป',
            onButtonPressed: () {
              if (_formKeyUsername.currentState!.validate()) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'กรุณากรอกชื่อผู้ใช้งาน';
              }
              if (value.length < 5) {
                return 'ต้องมีตัวอักษรอย่างน้อย 5 ตัว';
              }
              if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
                return 'ต้องขึ้นต้นด้วยตัวอักษรเท่านั้น';
              }
              return null;
            },
          ),
          _buildStepContent(
            messageTopic: "ขออีเมลเธอหน่อยได้ไหม\nเอาไว้ติดต่อเรื่องสำคัญน่ะ",
            formkey: _formKeyEmail,
            inputController: _emailController,
            hinttext: "Email",
            buttonText: 'ถัดไป',
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
          _buildStepContent(
            messageTopic: "มาตั้งรหัสผ่านกัน\nเอาแบบลับขั้นสุดยอดเลยนะ",
            formkey: _formKeyPassword,
            inputController: _passwordController,
            hinttext: "Password",
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
                return 'กรุณากรอกรหัสผ่าน';
              }
              if (value.length < 8) {
                return 'รหัสผ่านต้องยาวอย่างน้อย 8 ตัวนะ :)';
              }
              return null;
            },
          ),
          _buildStepContent(
            messageTopic: "มาลองทวนรหัสผ่านเมื่อกี้กัน\nเผื่อเธอลืมน่ะ XD",
            formkey: _formKeyCPassword,
            inputController: _confirmPasswordController,
            hinttext: "Confirm Password",
            buttonText: 'ลงทะเบียน',
            onButtonPressed: () {
              if (_formKeyCPassword.currentState!.validate()) {

                //ไว้เอาส่ง API
                print(_usernameController.text);
                print(_emailController.text);
                print(_passwordController.text);

                _pageController.nextPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'กรุณากรอกรหัสผ่าน';
              }
              if (value.length < 8) {
                return 'รหัสผ่านต้องยาวอย่างน้อย 8 ตัวนะ :)';
              }
              if (_passwordController.text != _confirmPasswordController.text) {
                return 'รหัสผ่านไม่ตรงกับรอบก่อนนะ :(';
              }
              return null;
            },
          ),
          _buildStepContent(
            messageTopic: "เยี่ยมเลยตอนนี้เรารู้จักกันแล้วนะ\nไปลองล็อคอินกัน !!",
            formkey: null,
            inputController: null,
            hinttext: "",
            buttonText: 'ไปกันต่ออ',
            onButtonPressed: () {

              context.go('/login');
            },
            isEnd: true,
          ),
        ],
      ),
    );
  }
}

Widget _buildStepContent({
  bool isEnd = false,
  required String messageTopic,
  required GlobalKey? formkey,
  required TextEditingController? inputController,
  FormFieldValidator<String>? validator,
  required String hinttext,
  required String buttonText,
  required VoidCallback onButtonPressed,
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Text(
              messageTopic,
              style: GoogleFonts.mali(
                fontSize: 18,
                height: 2.0,
                color: Color(0xFF464646),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 40.0),
          child: Image.asset(
            'assets/images/mascot.png',
            height: 200,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.image_not_supported,
                size: 100,
                color: Colors.grey,
              );
            },
          ),
        ),
        
        if(!isEnd) Container(
          margin: const EdgeInsets.only(top: 40.0),
          child: Form(
            key: formkey,
            child: TextFormField(
              controller: inputController,
              validator: validator,
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

        Container(
          margin: EdgeInsets.only(top: 30.0),
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
