import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/providers/userProvider.dart';
import 'package:intl/intl.dart';
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
    String userImg =
        userInfo.userPhoto ??
        "https://firebasestorage.googleapis.com/v0/b/healjaiapp-60ec3.firebasestorage.app/o/PostIMG%2F1757601646147.jpg?alt=media&token=c847c813-7b5c-496c-a1ee-958409a5858a";

    DateTime now = DateTime.now();
    String timeNow = DateFormat('HH:mm').format(now);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ElasticInUp(
      duration: Duration(milliseconds: 700),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 20,
                left: 15,
                right: 15,
              ),
              margin: EdgeInsets.only(top: 15, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFF78B465), width: 2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
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
                      : Container(
                        padding: EdgeInsets.all(0), // ความหนาของ border
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white, // สี border
                            width: 3, // ความหนา border
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              spreadRadius: 0,
                              blurRadius: 2,
                              offset: Offset(0, 2), // เงาด้านล่าง
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: CachedNetworkImageProvider(userImg),
                        ),
                      ),

                  const SizedBox(width: 12),
                  Expanded(
                    child: Transform.translate(
                      offset: Offset(0, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(screenWidth * 0.017),
                            decoration: BoxDecoration(
                              color: Color(0xFF78B465),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ส่งต่อเรื่องราวดีๆกันเถอะ :)',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.mali(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: screenWidth * 0.04,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '$timeNow น.',
                            style: GoogleFonts.mali(
                              color: Color(0xFF83B76D),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0, // ระยะจากขวา
              bottom: 5,
              child: Transform.rotate(
                angle: 0.3,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.045,
                    vertical: screenHeight * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: Color(0xFFE0E0E0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        spreadRadius: 0,
                        blurRadius: 2,
                        offset: Offset(0, 2), // เงาด้านล่าง
                      ),
                    ],
                  ),
                  child: Icon(Icons.favorite, color: Color(0xFFFD7D7E)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
