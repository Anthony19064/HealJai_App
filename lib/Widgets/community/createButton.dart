import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/providers/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

const Color kCardBorderColor = Color(0xFFCDE5CF);
const Color kLikeButtonBorderColor = Color(0xFFFFB8C3);

//ที่สร้างโพส
class PostCreationTrigger extends StatelessWidget {
  final VoidCallback onTap;
  const PostCreationTrigger({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserProvider>(context);

    return ElasticInUp(
      duration: Duration(milliseconds: 700),
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
              userInfo.userPhoto == null
                  ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: 100,
                      height: 23,
                      color: Colors.grey,
                    ),
                  )
                  : CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(userInfo.userPhoto!),
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
