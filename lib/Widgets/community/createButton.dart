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
    return ZoomIn(
      duration: Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: kCardBorderColor, width: 2.5),
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
                    style: GoogleFonts.mali(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.favorite, color: kLikeButtonBorderColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
