import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/Widgets/community/commuClass.dart';
import 'package:healjai_project/Widgets/community/photoView.dart';
import 'package:healjai_project/Widgets/community/postButton.dart';
import 'package:healjai_project/service/account.dart';

const Color kCardBorderColor = Color(0xFFCDE5CF);
const Color kLikeButtonBorderColor = Color(0xFFFFB8C3);
const Color kLikeButtonBackgroundColor = Color(0xFFFFF0F3);
const Color kCommentButtonBorderColor = Color(0xFFFFD97D);
const Color kCommentButtonBackgroundColor = Color(0xFFFFF8E5);
const Color kRepostButtonBorderColor = Color(0xFFC7C5FF);
const Color kRepostButtonBackgroundColor = Color(0xFFF2F1FF);
const Color kIconColor = Color(0xFF757575);
const Color kTextColor = Color(0xFF333333);
const Color kTimestampColor = Colors.grey;
const Color kDmBubbleColor = Color(0xFFC5E3C8);

class UserPostCard extends StatefulWidget {
  final Post post;
  final Map<String, dynamic> postNew;
  final VoidCallback onLikePressed;
  final VoidCallback onCommentPressed;
  final VoidCallback onMoreOptionsPressed;
  final VoidCallback onRepostPressed;

  const UserPostCard({
    super.key,
    required this.post,
    required this.postNew,
    required this.onLikePressed,
    required this.onCommentPressed,
    required this.onMoreOptionsPressed,
    required this.onRepostPressed,
  });

  @override
  State<UserPostCard> createState() => _UserPostCardState();
}

class _UserPostCardState extends State<UserPostCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Map<String, dynamic>? userInfo;
  late IconData likeIcon;
  late Color likeColor;
  late Color likeBorderColor;
  late Color likeBackgroundColor;

  @override
  void initState() {
    super.initState();

    // กำหนดค่าตัวแปร UI จาก post
    likeIcon = widget.post.isLiked ? Icons.favorite : Icons.favorite_border;
    likeColor = widget.post.isLiked ? Colors.red : kIconColor;
    likeBorderColor =
        widget.post.isLiked ? Colors.red.shade200 : kLikeButtonBorderColor;
    likeBackgroundColor =
        widget.post.isLiked ? Colors.red.shade50 : kLikeButtonBackgroundColor;

    // โหลด user info
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final user = await getuserById(widget.postNew['userID']);
    setState(() {
      userInfo = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userName = userInfo?['username'] ?? 'Loading...';
    final userImg = userInfo?['photoURL'] ?? '';
    final String postTxt = widget.postNew['infoPost'] ?? '';
    final String postImg = widget.postNew['img'];

    return ZoomIn(
      duration: Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: kCardBorderColor, width: 2.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(userImg),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.mali(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.post.timeAgo,
                      style: GoogleFonts.mali(
                        color: kTimestampColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Transform.translate(
                  offset: Offset(0, -10),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(
                      Icons.more_horiz,
                      color: Color(0xFF464646),
                      size: 40,
                    ),
                    onPressed: widget.onMoreOptionsPressed,
                  ),
                ),
              ],
            ),
            if (postTxt.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  postTxt,
                  style: GoogleFonts.mali(
                    fontSize: 15,
                    color: kTextColor,
                    height: 1.4,
                  ),
                ),
              ),
            if (postImg.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PhotoViewScreen(imagePath: postImg),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      postImg,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: widget.onLikePressed,
                  child: InteractionButton(
                    icon: likeIcon,
                    iconColor: likeColor,
                    label: widget.post.likes.toString(),
                    borderColor: likeBorderColor,
                    backgroundColor: likeBackgroundColor,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: widget.onCommentPressed,
                  child: InteractionButton(
                    icon: Icons.chat_bubble_outline,
                    label: widget.post.comments.length.toString(),
                    borderColor: kCommentButtonBorderColor,
                    backgroundColor: kCommentButtonBackgroundColor,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: widget.onRepostPressed,
                  child: InteractionButton(
                    icon: Icons.repeat,
                    label: widget.post.reposts.toString(),
                    borderColor: kRepostButtonBorderColor,
                    backgroundColor: kRepostButtonBackgroundColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
