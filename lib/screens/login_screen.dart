import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

import '../Widgets/LoginPage/InputField.dart';
import '../Widgets//LoginPage/SocialLogin.dart';

import '../service/authen.dart';
import '../providers/userProvider.dart';

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

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserInfo>(context);

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
                context.pop();
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
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            // รูปโลโก้
            ElasticInDown(
              duration: Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 200),
              child: Container(
                margin: EdgeInsets.only(top: 20, bottom: 10),
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Transform.scale(
                  scale: 0.8,
                  child: Lottie.asset('assets/animations/duck.json'),
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
                      labelText: 'username',
                      input_Controller: usernameController,
                      isPassword: false,
                    ),
                    InputField(
                      labelText: 'password',
                      input_Controller: passwordController,
                      isPassword: true,
                    ),
                  ],
                ),
              ),
            ),
            ElasticInLeft(
              duration: Duration(milliseconds: 800),
              child: Container(
                height: 40,
                margin: EdgeInsets.only(bottom: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      //
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
                    onPressed: () async {
                      final data = await signInwithEmail(
                        usernameController.text,
                        passwordController.text,
                      );

                      final user = data['user'];
                      if (user != null) {
                        await saveUserToLocal({
                          'userId': user['id'],
                          'userName': user['username'],
                          'userMail': user['mail'],
                          'userPhoto': user['photoURL'],
                        });

                        await userInfo.setUserInfo();
                        context.pop();
                      } else {
                        print('Login canceled or failed');
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
                    margin: EdgeInsets.only(bottom: 10),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Google
                      Sociallogin(
                        iconPath: 'assets/images/google.png', // ไอค่อน google
                        onPressed: () async {
                          final userCredential = await signInWithGoogle();
                          final user = userCredential?.user;
                          if (userCredential != null) {
                            await saveUserToLocal({
                              'userId': user?.uid,
                              'userName': user?.displayName,
                              'userMail': user?.email,
                              'userPhoto': user?.photoURL,
                            });

                            await userInfo.setUserInfo();
                            context.pop();
                          } else {
                            print('Login canceled or failed');
                          }
                        },
                      ),
                      const SizedBox(width: 40),
                      //Facebook
                      Sociallogin(
                        iconPath:
                            'assets/images/facebook.png', // ไอค่อน Facebook
                        onPressed: () {
                          // facebook
                        },
                      ),
                    ],
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

  const ButtonLogin({super.key, required this.onPressed});

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
          child: Text(
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
