import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Sociallogin extends StatefulWidget { // สังเกตว่าชื่อคลาสคือ SocialLogin (L ใหญ่)
  final String iconPath;
  final String text;
  final VoidCallback onPressed;

  const Sociallogin({
    Key? key,
    required this.iconPath,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<Sociallogin> createState() => _SocialLoginState();
}

class _SocialLoginState extends State<Sociallogin> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, 
      height: 55, 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          // **ปรับสีขอบเมื่อกด:** ให้ตรงกับภาพที่เคยให้มา (เขียว) หรือตามที่คุณต้องการ
          color: _isPressed ? const Color(0xFF78B465) : const Color(0xFFE0E0E0), 
          width: 2, 
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onHighlightChanged: (value) {
            setState(() {
              _isPressed = value;
            });
          },
          splashColor: const Color(0xFF78B465).withOpacity(0.3), // สีเวลาคลื่นกระจาย
          highlightColor: const Color(0xFF78B465).withOpacity(0.1), // ปรับให้โปร่งแสงขึ้นเล็กน้อย
          borderRadius: BorderRadius.circular(15.0), 
          child: Stack( 
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  width: 30, // **ปรับขนาดไอคอนให้เหมาะสม**
                  height: 30,
                  child: Image.asset(widget.iconPath),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  widget.text, 
                  style: GoogleFonts.mali(
                    color: Color(0xFF464646),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}