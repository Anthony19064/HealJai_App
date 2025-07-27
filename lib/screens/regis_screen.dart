import 'package:flutter/material.dart';
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
  final TextEditingController _confirmPasswordController = TextEditingController();

  final PageController _pageController = PageController();

  String? _usernameError; // New: Error for username
  String? _emailError;    // New: Error for email
  String? _passwordError; // New: Error for password
  String? _confirmPasswordError; // Error for confirm password (replaces _passwordMatchError)

  @override
  void initState() {
    super.initState();
    // ถ้าพิมพ์แจ้งเตือนหาย
    _usernameController.addListener(_clearUsernameError);
    _emailController.addListener(_clearEmailError);
    _passwordController.addListener(_clearPasswordError);
    _confirmPasswordController.addListener(_clearConfirmPasswordError);
  }

  void _clearUsernameError() {
    if (_usernameError != null) setState(() => _usernameError = null);
  }

  void _clearEmailError() {
    if (_emailError != null) setState(() => _emailError = null);
  }

  void _clearPasswordError() {
    if (_passwordError != null) setState(() => _passwordError = null);
  }

  void _clearConfirmPasswordError() {
    if (_confirmPasswordError != null) setState(() => _confirmPasswordError = null);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_clearUsernameError);
    _emailController.removeListener(_clearEmailError);
    _passwordController.removeListener(_clearPasswordError);
    _confirmPasswordController.removeListener(_clearConfirmPasswordError);

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
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
              // Clear errors when going back
              setState(() {
                _usernameError = null;
                _emailError = null;
                _passwordError = null;
                _confirmPasswordError = null;
              });
            }
          },
        ),
        title: Text(
          'ยินดีที่ได้รู้จัก',
          style: GoogleFonts.mali(
            color: const Color(0xFF78B465),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // ปิดการปัดด้วยนิ้ว
        onPageChanged: (index) {
          // Clear errors when page changes (e.g., from pressing 'next')
          setState(() {
            _usernameError = null;
            _emailError = null;
            _passwordError = null;
            _confirmPasswordError = null;
          });
        },
        children: [
          _buildStepContent(
            messageBox: _buildUsernameMessageBox(),
            inputField: _buildUsernameInputField(),
            buttonText: 'ถัดไป',
            errorText: _usernameError, // Pass username error
            onButtonPressed: () {
              if (_usernameController.text.trim().isEmpty) {
                setState(() => _usernameError = 'กรุณากรอกชื่อผู้ใช้งาน');
                return;
              }
              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
            },
          ),
          _buildStepContent(
            messageBox: _buildEmailMessageBox(),
            inputField: _buildEmailInputField(),
            buttonText: 'ถัดไป',
            errorText: _emailError, // Pass email error
            onButtonPressed: () {
              final email = _emailController.text.trim();
              if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) { // More robust email regex
                setState(() => _emailError = 'กรุณากรอกอีเมลที่ถูกต้อง');
                return;
              }
              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
            },
          ),
          _buildStepContent(
            messageBox: _buildPasswordMessageBox(),
            inputField: _buildPasswordInputField(),
            buttonText: 'ถัดไป',
            errorText: _passwordError, // Pass password error
            onButtonPressed: () {
              if (_passwordController.text.trim().length < 6) {
                setState(() => _passwordError = 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร');
                return;
              }
              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
            },
          ),
          _buildStepContent(
            messageBox: _buildConfirmPasswordMessageBox(),
            inputField: _buildConfirmPasswordInputField(),
            buttonText: 'ลงทะเบียน',
            errorText: _confirmPasswordError, 
            onButtonPressed: () {
              final password = _passwordController.text.trim();
              final confirmPassword = _confirmPasswordController.text.trim();

              if (password != confirmPassword) {
                setState(() => _confirmPasswordError = 'รหัสผ่านไม่ตรงกัน');
                return;
              }

             
              print('Initiating final registration with:');
              print('Username: ${_usernameController.text.trim()}');
              print('Email: ${_emailController.text.trim()}');
              print('Password: $password'); 
              print('Registration successful (simulated)!');

              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
            },
          ),
          _buildStepContent(
            messageBox: _buildWelcomeMessageBox(),
            inputField: const SizedBox.shrink(), 
            buttonText: 'ถัดไป',
            onButtonPressed: () {
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent({
    required Widget messageBox,
    required Widget inputField,
    required String buttonText,
    required VoidCallback onButtonPressed,
    String? errorText, 
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 20.0),
            child: messageBox,
          ),
          Container(
            margin: const EdgeInsets.only(top: 40.0),
            child: Image.asset(
              'assets/images/mascot.png',
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 40.0),
            child: inputField,
          ),
          // โชว์ข้อความล่างฟร์ม
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0), 
              child: Text(
                errorText,
                style: GoogleFonts.mali(
                  color: Colors.red,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center, 
              ),
            ),
          Container(
            margin: EdgeInsets.only(top: (errorText != null) ? 10.0 : 30.0), 
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

  Widget _buildUsernameMessageBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'ฮัลโหลล -',
            textAlign: TextAlign.center,
            style: GoogleFonts.mali(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'ชื่อของเธอคืออะไรหรออ ?',
            textAlign: TextAlign.center,
            style: GoogleFonts.mali(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailMessageBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'ขออีเมลเธอหน่อยได้ไหม',
            textAlign: TextAlign.center,
            style: GoogleFonts.mali(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'เอาไว้ติดต่อเรื่องสำคัญนะ',
            textAlign: TextAlign.center,
            style: GoogleFonts.mali(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordMessageBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'ขอรหัสผ่านเธอหน่อยสิ',
            textAlign: TextAlign.center,
            style: GoogleFonts.mali(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'เอาแบบลับสุดยอดเลยนะ',
            textAlign: TextAlign.center,
            style: GoogleFonts.mali(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordMessageBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'มาลองทวนรหัสเมื่อกี้',
            textAlign: TextAlign.center,
            style: GoogleFonts.mali(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'กันอีกรอบดีกว่า เพื่อเธอไม่ลืม',
            textAlign: TextAlign.center,
            style: GoogleFonts.mali(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessageBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'สุดยอด ยินดีต้อนรับเข้าสู่',
            textAlign: TextAlign.center,
            style: GoogleFonts.mali(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'พื้นที่ HealJai นะ',
            textAlign: TextAlign.center,
            style: GoogleFonts.mali(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameInputField() {
    return TextField(
      controller: _usernameController,
      decoration: InputDecoration(
        hintText: 'username',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      ),
      style: GoogleFonts.mali(fontSize: 16),
    );
  }

  Widget _buildEmailInputField() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        hintText: 'Email',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      ),
      style: GoogleFonts.mali(fontSize: 16),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordInputField() {
    return TextField(
      controller: _passwordController,
      decoration: InputDecoration(
        hintText: 'password',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      ),
      style: GoogleFonts.mali(fontSize: 16),
      obscureText: true,
    );
  }

  Widget _buildConfirmPasswordInputField() {
    return TextField(
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        hintText: 'confirm password',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      ),
      style: GoogleFonts.mali(fontSize: 16),
      obscureText: true,
    );
  }
}