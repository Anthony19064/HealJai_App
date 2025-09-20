import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/providers/DiaryProvider.dart';
import 'package:healjai_project/providers/TreeProvider.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

import 'package:healjai_project/Widgets/LoginPage/InputField.dart';
import 'package:healjai_project/Widgets/LoginPage/SocialLogin.dart';

import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/token.dart';
import 'package:healjai_project/providers/userProvider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // key ของ Form Login
  final TextEditingController usernameController =
      TextEditingController(); // ตัวเก็บค่า username
  final TextEditingController passwordController =
      TextEditingController(); // ตัวเก็บค่า password

  bool isLoading = false;
  // StateMachineController? _controller;
  SMIInput<bool>? _isTyping;

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserProvider>(context);
    final TreeInfo = Provider.of<TreeProvider>(context);
    final DiaryInfo = Provider.of<DiaryProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: ElasticInDown(
          duration: Duration(milliseconds: 800),
          child: Container(
            margin: EdgeInsets.only(left: 15),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF464646)),
              onPressed: () {
                context.go('/');
              },
            ),
          ),
        ),
        title: ElasticInDown(
          duration: Duration(milliseconds: 800),
          child: Text(
            'HealJai',
            style: GoogleFonts.mali(
              fontSize: 35,
              fontWeight: FontWeight.w700,
              color: Color(0xFF78B465),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            // รูปโลโก้
            ElasticInDown(
              duration: Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 200),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.25,
                child: Transform.scale(
                  scale: 0.8,
                  child: RiveAnimation.asset(
                          'assets/animations/rives/goose_login.riv',
                          onInit: (artboard) {
                            final controller =
                                StateMachineController.fromArtboard(
                                  artboard,
                                  'LoginState',
                                );
                            if (controller != null) {
                              artboard.addController(controller);
                              // _controller = controller;

                              _isTyping = controller.findInput<bool>(
                                'isTyping',
                              );
                              _isTyping?.value = false;
                              if (_isTyping == null) {
                                print("❌ ไม่พบตัวแปร StateNum");
                              }
                            }
                          },
                        ),
                ),
              ),
            ),
            ElasticInLeft(
              duration: Duration(milliseconds: 800),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    InputField(
                      labelText: 'email',
                      input_Controller: usernameController,
                      isPassword: false,
                      onChanged:(value) {
                        if(value.isNotEmpty){
                          _isTyping?.value = true; 
                        }
                      },
                      validator: (value) {
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกข้อมูลให้ครบถ้วน';
                        }
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'รูปแบบอีเมลไม่ถูกต้อง';
                        }
                        return null;
                      },
                    ),
                    InputField(
                      labelText: 'password',
                      input_Controller: passwordController,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกข้อมูลให้ครบถ้วน';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            ElasticInLeft(
              duration: Duration(milliseconds: 800),
              child: Container(
                height: 40,
                margin: EdgeInsets.only(bottom: 15),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.push('/forget_pass');
                    },
                    child: Text(
                      'ลืมรหัสผ่าน ?',
                      style: GoogleFonts.mali(
                        color: Color(0xFF5C5C5C),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ElasticInRight(
              duration: Duration(milliseconds: 800),
              child: Column(
                children: [
                  ButtonLogin(
                    isLoading: isLoading,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });
                        final data = await signInwithEmail(
                          usernameController.text,
                          passwordController.text,
                        );

                        if (data['success']) {
                          final user = data['user'];
                          await saveUserToLocal({
                            'userId': user['id'],
                            'userName': user['username'],
                            'userMail': user['mail'],
                            'userPhoto': user['photoURL'],
                          });
                          await saveJWTAccessToken(data['accessToken']);
                          await saveJWTRefreshToken(data['refreshToken']);
                          await userInfo.setUserInfo();
                          await TreeInfo.fetchTreeAge(context);
                          await DiaryInfo.fetchTaskCount(context);
                          context.pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
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
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                  ),
                  ButtonRegister(),
                ],
              ),
            ),
            ElasticInUp(
              duration: Duration(milliseconds: 800),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: Stack(
                      children: [
                        Container(
                          height: 40,
                          child: Divider(
                            color: Color(0xFFE0E0E0),
                            thickness: 2,
                          ),
                        ),
                        Center(
                          child: Container(
                            color: Color(0xFFFFF8F0),
                            height: 40,
                            width: 100,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'หรือ',
                                style: GoogleFonts.mali(
                                  color: Color(0xFF787878),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Sociallogin(
                      iconPath: 'assets/images/google.png',
                      text: 'Sign in with Google', // ไอค่อน google
                      onPressed: () async {
                        final data = await signInWithGoogle();
                        if (data['success']) {
                          final user = data['user'];
                          await saveUserToLocal({
                            'userId': user['id'],
                            'userName': user['username'],
                            'userMail': user['mail'],
                            'userPhoto': user['photoURL'],
                          });
                          await saveJWTAccessToken(data['accessToken']);
                          await saveJWTRefreshToken(data['refreshToken']);
                          await userInfo.setUserInfo();
                          await TreeInfo.fetchTreeAge(context);
                          await DiaryInfo.fetchTaskCount(context);
                          context.pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
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
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ButtonLogin extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const ButtonLogin({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF78B465), // Green button color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 0,
          ),
          child:
              isLoading
                  ? Lottie.asset('assets/animations/lotties/loading.json')
                  : Text(
                    'Sign in',
                    style: GoogleFonts.mali(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
      ),
    );
  }
}

class ButtonRegister extends StatelessWidget {
  const ButtonRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'ยังไม่มีบัญชีหรอ?',
            style: GoogleFonts.mali(
              color: Color(0xFF5C5C5C),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextButton(
            onPressed: () {
              context.push('/regis');
            },
            child: Text(
              'สร้างบัญชี',
              style: GoogleFonts.mali(
                color: Color(0xFF78B465),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
