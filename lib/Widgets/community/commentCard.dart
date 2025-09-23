import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/service/account.dart';
import 'package:shimmer/shimmer.dart';

class CommentCard extends StatefulWidget {
  final Map<String, dynamic> comment;
  const CommentCard({super.key, required this.comment});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  Map<String, dynamic> userInfo = {}; // ข้อมูลของเจ้าของโพส

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  // เรียกข้อมูลเจ้าของโพส
  Future<void> fetchUserInfo() async {
    final userID = widget.comment['ownerComment'];
    final user = await getuserById(userID);
    if (!mounted) return;
    setState(() {
      userInfo = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userImg = userInfo['photoURL'];
    final userName = userInfo['username'];

    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userImg == null
              ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              )
              : CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(userInfo['photoURL']),
              ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                userName == null
                    ? Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 100,
                        height: 29,
                        color: Colors.grey,
                      ),
                    )
                    : Transform.translate(
                      offset: Offset(0, -5),
                      child: Text(
                        userName,
                        style: GoogleFonts.mali(
                          color: Color(0xFF78B465),
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ),
                Text(
                  widget.comment['infoComment'],
                  style: GoogleFonts.mali(
                    color: Color(0xFF464646),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
