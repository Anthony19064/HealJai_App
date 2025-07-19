import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'HealJai',
            style: GoogleFonts.mali(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Color(0xFF78B465),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: Offset(0, 8), // เงาด้านล่าง
                ),
              ],
              border: Border.all(
                color: Colors.white, // สีขอบ
                width: 3,
              ),
            ),
            child: GestureDetector(
              onTap: (){
                context.go('/login');
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/makima.jpg'),
                radius: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
