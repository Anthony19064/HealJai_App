import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/Widgets/community/commuClass.dart';
import 'package:healjai_project/Widgets/community/comment.dart';
import 'package:healjai_project/Widgets/community/createButton.dart';
import 'package:healjai_project/Widgets/community/fullCreate.dart';
import 'package:healjai_project/Widgets/community/postCard.dart';
import 'package:healjai_project/Widgets/community/fullCreate.dart';
import 'package:healjai_project/Widgets/bottom_nav.dart';
import 'package:healjai_project/Widgets/header_section.dart';
import 'package:healjai_project/service/commu.dart';

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
      reposts: 5,
      comments: [
        Comment(
          username: 'User_2',
          avatarUrl: 'https://i.pravatar.cc/150?img=25',
          text: 'Great post!',
        ),
        Comment(
          username: 'User_3',
          avatarUrl: 'https://i.pravatar.cc/150?img=32',
          text: 'Love it!',
        ),
      ],
    ),
    Post(
      id: 'post_1',
      username: 'User_1',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      timeAgo: '1d ago',
      postText: 'Ex text post . . . . . .',
      likes: 15,
      reposts: 5,
      comments: [
        Comment(
          username: 'User_2',
          avatarUrl: 'https://i.pravatar.cc/150?img=25',
          text: 'Great post!',
        ),
        Comment(
          username: 'User_3',
          avatarUrl: 'https://i.pravatar.cc/150?img=32',
          text: 'Love it!',
        ),
      ],
    ),
    Post(
      id: 'post_1',
      username: 'User_1',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      timeAgo: '1d ago',
      postText: 'Ex text post . . . . . .',
      likes: 15,
      reposts: 5,
      comments: [
        Comment(
          username: 'User_2',
          avatarUrl: 'https://i.pravatar.cc/150?img=25',
          text: 'Great post!',
        ),
        Comment(
          username: 'User_3',
          avatarUrl: 'https://i.pravatar.cc/150?img=32',
          text: 'Love it!',
        ),
      ],
    ),
    Post(
      id: 'post_1',
      username: 'User_1',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      timeAgo: '1d ago',
      postText: 'Ex text post . . . . . .',
      likes: 15,
      reposts: 5,
      comments: [
        Comment(
          username: 'User_2',
          avatarUrl: 'https://i.pravatar.cc/150?img=25',
          text: 'Great post!',
        ),
        Comment(
          username: 'User_3',
          avatarUrl: 'https://i.pravatar.cc/150?img=32',
          text: 'Love it!',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    fetchPost();
  }

  List<Map<String, dynamic>> post = []; // List ข้อมูลโพสทั้งหมด

  // ดึงโพส
  Future<void> fetchPost() async {
    final data = await getPosts();
    setState(() {
      post = data;
    });
    print(post[0]);
  }

  // ============== ฟังก์ชันใหม่สำหรับอัปเดตโพสต์ ==============
  void _updatePost(Post postToUpdate, String newText, String? newImagePath) {
    setState(() {
      final postIndex = _posts.indexWhere((p) => p.id == postToUpdate.id);
      if (postIndex != -1) {
        _posts[postIndex].postText = newText;
        _posts[postIndex].imageUrl = newImagePath;
      }
    });
    _showSuccessSnackBar('แก้ไขโพสต์สำเร็จ');
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

  void _incrementReposts(String postId) {
    setState(() {
      final post = _posts.firstWhere((p) => p.id == postId);
      post.reposts++;
    });
    _showSuccessSnackBar('Reposted!');
  }

  // โชว์ Popup Comment
  void _showCommentDialog(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) {
        return CommentsDialog(
          post: post,
          onCommentAdded: () {
            setState(() {});
          },
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: GoogleFonts.mali(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.green[600],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showPostOptions(Post post) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        List<Widget> options = [];
        if (post.username == 'Me') {
          options.addAll([
            // ============== ▼▼▼ แก้ไข onTap ของปุ่ม "แก้ไขโพสต์" ▼▼▼ ==============
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text('แก้ไขโพสต์', style: GoogleFonts.mali()),
              onTap: () {
                Navigator.pop(modalContext); // ปิดเมนูตัวเลือก
                _showEditPostModal(post); // เปิดหน้าต่างแก้ไข
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                'ลบโพสต์',
                style: GoogleFonts.mali(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(modalContext);
                setState(() {
                  _posts.removeWhere((p) => p.id == post.id);
                });
                _showSuccessSnackBar('ลบโพสต์สำเร็จ');
              },
            ),
          ]);
        }
        options.add(
          ListTile(
            leading: const Icon(Icons.report),
            title: Text('รายงาน', style: GoogleFonts.mali()),
            onTap: () {
              Navigator.pop(modalContext);
              _showSuccessSnackBar('รายงานโพสต์แล้ว');
            },
          ),
        );
        options.add(
          ListTile(
            leading: const Icon(Icons.save),
            title: Text('บันทึกโพสต์', style: GoogleFonts.mali()),
            onTap: () {
              Navigator.pop(modalContext);
              _showSuccessSnackBar('บันทึกโพสต์แล้ว');
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
          child: Wrap(children: options),
        );
      },
    );
  }

  //หน้าบ้านเพิ่มโพส
  void _addPost(String text, String? imagePath) {
    if (text.isNotEmpty || imagePath != null) {
      setState(() {
        final newPost = Post(
          id: 'post_${Random().nextInt(9999)}',
          username: 'Me',
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
          timeAgo: 'Just now',
          postText: text,
          imageUrl: imagePath,
        );
        _posts.insert(0, newPost);
      });
    }
  }

  // ฟังก์ชันสำหรับ "สร้าง" โพสต์
  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: FullScreenPostCreator(
            // ไม่ส่ง postToEdit ไป = โหมดสร้างใหม่
            onPost: (text, imagePath) {
              _addPost(text, imagePath);
            },
          ),
        );
      },
    );
  }

  // ============== ▼▼▼ ฟังก์ชันใหม่สำหรับเปิด Modal "แก้ไข" ▼▼▼ ==============
  void _showEditPostModal(Post postToEdit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: FullScreenPostCreator(
            postToEdit: postToEdit, // <--- ส่งโพสต์ที่ต้องการแก้ไขเข้าไป
            onPost: (newText, newImagePath) {
              _updatePost(postToEdit, newText, newImagePath);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB),
      bottomNavigationBar: const BottomNavBar(),
      body: RefreshIndicator(
        onRefresh: fetchPost,
        color: Color(0xFF78B465), // สีวงกลม
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              const HeaderSection(),
              PostCreationTrigger(onTap: _showCreatePostModal), // widget สร้างโพส
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: post.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final postold = _posts[index];
                    final postNew = post[index];
                    return UserPostCard(
                      post: postold,
                      postNew: postNew,
                      onLikePressed: () => _toggleLike(postold.id),
                      onCommentPressed: () => _showCommentDialog(postold),
                      onMoreOptionsPressed: () => _showPostOptions(postold),
                      onRepostPressed: () => _incrementReposts(postold.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============== CONSTANTS ==============

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
