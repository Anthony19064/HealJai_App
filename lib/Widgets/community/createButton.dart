import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kCardBorderColor = Color(0xFFCDE5CF);
const Color kLikeButtonBorderColor = Color(0xFFFFB8C3);

//ที่สร้างโพส
class PostCreationTrigger extends StatelessWidget {
  final VoidCallback onTap;
  const PostCreationTrigger({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElasticInUp(
      duration: Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: EdgeInsets.only(top: 15, bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xFF78B465), width: 2),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ส่งต่อเรื่องราวดีๆกันเถอะ :)',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mali(
                    color: Color(0xFF464646),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.favorite, color: Color(0xFFFD7D7E)),
            ],
          ),
        ),
      ),
    );
  }
}
