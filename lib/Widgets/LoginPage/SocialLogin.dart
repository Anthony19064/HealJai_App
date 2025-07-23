import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Sociallogin extends StatefulWidget {
  final String iconPath;
  final VoidCallback onPressed;

  const Sociallogin({
    Key? key,
    required this.iconPath,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<Sociallogin> createState() => _SocialloginState();
}

class _SocialloginState extends State<Sociallogin> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color: _isPressed ? Colors.white : Color(0xFFE0E0E0),
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
          splashColor: Color(0xFF78B465).withOpacity(0.3), // สีเวลาคลื่นกระจาย
          highlightColor: Color(0xFF78B465),
          borderRadius: BorderRadius.circular(10.0),
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 30,
              height: 30,
              child: Image.asset(widget.iconPath),
            ),
          ),
        ),
      ),
    );
  }
}
