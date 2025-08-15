import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

// สมมติว่ามีหน้าสำหรับแก้ไขโพสต์
class EditPostScreen extends StatelessWidget {
  final Post post;
  const EditPostScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('แก้ไขโพสต์', style: GoogleFonts.mali())),
      body: Center(
        child: Text('กำลังแก้ไข: ${post.postText}', style: GoogleFonts.mali()),
      ),
    );
  }
}


class Post {
  final String id;
  final String username;
  final String avatarUrl;
  final String timeAgo;
  String postText;
  int likes;
  bool isLiked;
  List<String> comments;

  Post({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.timeAgo,
    required this.postText,
    this.likes = 0,
    this.isLiked = false,
    List<String>? comments,
  }) : comments = comments ?? [];
}

class CommuScreen extends StatefulWidget {
  const CommuScreen({super.key});

  @override
  State<CommuScreen> createState() => _CommuScreenState();
}

class _CommuScreenState extends State<CommuScreen> {
  final List<Post> _posts = [
    Post(
      id: 'post_1',
      username: 'User_1',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      timeAgo: '1d ago',
      postText: 'Ex text post . . . . . .',
      likes: 15,
      comments: ['Great post!', 'Love it!'],
    ),
  ];

  void _addPost(String text) {
    if (text.isNotEmpty) {
      setState(() {
        final newPost = Post(
          id: 'post_${Random().nextInt(9999)}',
          username: 'Me',
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
          timeAgo: 'Just now',
          postText: text,
        );
        _posts.insert(0, newPost);
      });
    }
  }

  void _toggleLike(String postId) {
    setState(() {
      final post = _posts.firstWhere((p) => p.id == postId);
      post.isLiked = !post.isLiked;
      if (post.isLiked) {
        post.likes++;
      } else {
        post.likes--;
      }
    });
  }

  void _showCommentDialog(Post post) {
    showDialog(
      context: context,
      builder: (context) {
        final commentController = TextEditingController();
        return AlertDialog(
          title: Text('แสดงความคิดเห็น', style: GoogleFonts.mali()),
          content: TextField(
            controller: commentController,
            autofocus: true,
            style: GoogleFonts.mali(),
            decoration: InputDecoration(
              hintText: "ความคิดเห็นของคุณ...",
              hintStyle: GoogleFonts.mali(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('ยกเลิก', style: GoogleFonts.mali())),
            TextButton(
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  setState(() {
                    post.comments.add(commentController.text);
                  });
                }
                Navigator.pop(context);
              },
              child: Text('ส่ง', style: GoogleFonts.mali()),
            ),
          ],
        );
      },
    );
  }

  void _showPostOptions(Post post) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      builder: (context) {
        List<Widget> options = [];

        if (post.username == 'Me') {
          options.addAll([
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text('แก้ไขโพสต์', style: GoogleFonts.mali()),
              onTap: () {
                // 1. สั่งปิด BottomSheet ก่อน
                Navigator.pop(context);

                // 2. จากนั้นค่อยสั่งให้เปลี่ยนไปหน้าใหม่
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => EditPostScreen(post: post)),
                // );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text('ลบโพสต์', style: GoogleFonts.mali(color: Colors.red)),
              onTap: () {
                setState(() {
                  _posts.removeWhere((p) => p.id == post.id);
                });
                Navigator.pop(context);
              },
            ),
          ]);
        }

        options.add(
          ListTile(
            leading: const Icon(Icons.report),
            title: Text('รายงาน', style: GoogleFonts.mali()),
            onTap: () {
              print('Report post: ${post.id}');
              Navigator.pop(context);
            },
          ),
        );

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7EB),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Wrap(
            children: options,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _posts.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          if (index == 0) {
            return CreatePostInput(onPost: _addPost);
          }
          final post = _posts[index - 1];
          return UserPostCard(
            post: post,
            onLikePressed: () => _toggleLike(post.id),
            onCommentPressed: () => _showCommentDialog(post),
            onMoreOptionsPressed: () => _showPostOptions(post),
          );
        },
      ),
    );
  }
}

class CreatePostInput extends StatefulWidget {
  final Function(String) onPost;
  const CreatePostInput({super.key, required this.onPost});
  @override
  State<CreatePostInput> createState() => _CreatePostInputState();
}

class _CreatePostInputState extends State<CreatePostInput> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePost() {
    widget.onPost(_controller.text);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kCardBorderColor, width: 2.5)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Column(
            children: [
              CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1')),
              SizedBox(height: 4),
              Text('09.03 น.',
                  style:
                      TextStyle(color: kTimestampColor, fontSize: 12)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              style: GoogleFonts.mali(),
              decoration: InputDecoration(
                  filled: true,
                  fillColor: kDmBubbleColor,
                  hintText: 'ส่งต่อเรื่องราวดีๆกันเถอะ :)',
                  hintStyle: GoogleFonts.mali(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none)),
              minLines: 1,
              maxLines: 4,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              onPressed: _handlePost,
              icon: const Icon(Icons.favorite),
              iconSize: 32,
              color: kLikeButtonBorderColor,
              style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(
                      color: kLikeButtonBorderColor.withOpacity(0.5),
                      width: 1.5)),
            ),
          )
        ],
      ),
    );
  }
}

const Color kCardBorderColor = Color(0xFFCDE5CF);
const Color kLikeButtonBorderColor = Color(0xFFFFB8C3);
const Color kLikeButtonBackgroundColor = Color(0xFFFFF0F3);
const Color kCommentButtonBorderColor = Color(0xFFFFD97D);
const Color kCommentButtonBackgroundColor = Color(0xFFFFF8E5);
const Color kShareButtonBorderColor = Color(0xFFC7C5FF);
const Color kShareButtonBackgroundColor = Color(0xFFF2F1FF);
const Color kIconColor = Color(0xFF757575);
const Color kTextColor = Color(0xFF333333);
const Color kTimestampColor = Colors.grey;
const Color kDmBubbleColor = Color(0xFFC5E3C8);

class UserPostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLikePressed;
  final VoidCallback onCommentPressed;
  final VoidCallback onMoreOptionsPressed;
  const UserPostCard({
    super.key,
    required this.post,
    required this.onLikePressed,
    required this.onCommentPressed,
    required this.onMoreOptionsPressed,
  });
  @override
  Widget build(BuildContext context) {
    final likeIcon = post.isLiked ? Icons.favorite : Icons.favorite_border;
    final likeColor = post.isLiked ? Colors.red : kIconColor;
    final likeBorderColor =
        post.isLiked ? Colors.red.shade200 : kLikeButtonBorderColor;
    final likeBackgroundColor =
        post.isLiked ? Colors.red.shade50 : kLikeButtonBackgroundColor;

    return Container(
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
                  radius: 22, backgroundImage: NetworkImage(post.avatarUrl)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.username,
                      style: GoogleFonts.mali(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: kTextColor)),
                  const SizedBox(height: 2),
                  Text(post.timeAgo,
                      style: GoogleFonts.mali(
                          color: kTimestampColor, fontSize: 13)),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.more_horiz,
                    color: kTextColor.withOpacity(0.8), size: 30),
                onPressed: onMoreOptionsPressed,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(post.postText,
              style:
                  GoogleFonts.mali(fontSize: 15, color: kTextColor, height: 1.4)),
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
            ],
          ),
        ],
      ),
    );
  }
}

class InteractionButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final Color borderColor;
  final Color backgroundColor;
  const InteractionButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.borderColor,
      required this.backgroundColor,
      this.iconColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor ?? kIconColor),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.mali(
                  color: kIconColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}