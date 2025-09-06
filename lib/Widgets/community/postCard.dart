import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/Widgets/community/commuClass.dart';
import 'package:healjai_project/Widgets/community/photoView.dart';
import 'package:healjai_project/Widgets/community/postButton.dart';

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

class UserPostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLikePressed;
  final VoidCallback onCommentPressed;
  final VoidCallback onMoreOptionsPressed;
  final VoidCallback onRepostPressed;

  const UserPostCard({
    super.key,
    required this.post,
    required this.onLikePressed,
    required this.onCommentPressed,
    required this.onMoreOptionsPressed,
    required this.onRepostPressed,
  });
  @override
  Widget build(BuildContext context) {
    final likeIcon = post.isLiked ? Icons.favorite : Icons.favorite_border;
    final likeColor = post.isLiked ? Colors.red : kIconColor;
    final likeBorderColor =
        post.isLiked ? Colors.red.shade200 : kLikeButtonBorderColor;
    final likeBackgroundColor =
        post.isLiked ? Colors.red.shade50 : kLikeButtonBackgroundColor;

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
                  backgroundImage: NetworkImage(post.avatarUrl),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username,
                      style: GoogleFonts.mali(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      post.timeAgo,
                      style: GoogleFonts.mali(
                        color: kTimestampColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: kTextColor.withOpacity(0.8),
                    size: 30,
                  ),
                  onPressed: onMoreOptionsPressed,
                ),
              ],
            ),
            if (post.postText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  post.postText,
                  style: GoogleFonts.mali(
                    fontSize: 15,
                    color: kTextColor,
                    height: 1.4,
                  ),
                ),
              ),
            if (post.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                PhotoViewScreen(imagePath: post.imageUrl!),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.file(
                      File(post.imageUrl!),
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
                  onTap: onLikePressed,
                  child: InteractionButton(
                    icon: likeIcon,
                    iconColor: likeColor,
                    label: post.likes.toString(),
                    borderColor: likeBorderColor,
                    backgroundColor: likeBackgroundColor,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onCommentPressed,
                  child: InteractionButton(
                    icon: Icons.chat_bubble_outline,
                    label: post.comments.length.toString(),
                    borderColor: kCommentButtonBorderColor,
                    backgroundColor: kCommentButtonBackgroundColor,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onRepostPressed,
                  child: InteractionButton(
                    icon: Icons.repeat,
                    label: post.reposts.toString(),
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
