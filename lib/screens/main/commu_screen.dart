import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/Widgets/community/createButton.dart';
import 'package:healjai_project/Widgets/community/fullCreate.dart';
import 'package:healjai_project/Widgets/community/postCard.dart';
import 'package:healjai_project/Widgets/bottom_nav.dart';
import 'package:healjai_project/Widgets/header_section.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/commu.dart';

class CommuScreen extends StatefulWidget {
  const CommuScreen({super.key});

  @override
  State<CommuScreen> createState() => _CommuScreenState();
}

class _CommuScreenState extends State<CommuScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> post = []; // List ข้อมูลโพสทั้งหมด
  int limit = 5;
  int page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    fetchPost();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        // เลื่อนถึงล่างสุดแล้ว
        fetchMorePosts();
      }
    });
  }

  // ดึงโพส
  Future<void> fetchPost() async {
    final data = await getPosts(0, page * limit);
    if (data.length < limit) {
      setState(() {
        hasMore = false;
      });
    }
    if (!mounted) return;
    setState(() {
      post = data;
    });
  }

  Future<void> fetchMorePosts() async {
    if (!hasMore) return;
    if (isLoadingMore) return;
    setState(() {
      isLoadingMore = true;
    });
    final newPosts = await getPosts(page, limit);
    if (newPosts.length < limit) {
      setState(() {
        hasMore = false;
      });
    }
    setState(() {
      post = [...post, ...newPosts];
      page++;
    });
    setState(() {
      isLoadingMore = false;
    });
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

  Future<void> _showPostOptions(Map<String, dynamic> postObj) async {
    final postID = postObj['_id'];
    final ownerPostId = postObj['userID'];
    final String myuserId = await getUserId();

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        List<Widget> options = [];
        if (ownerPostId == myuserId) {
          options.addAll([
            // ============== ▼▼▼ แก้ไข onTap ของปุ่ม "แก้ไขโพสต์" ▼▼▼ ==============
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text('แก้ไขโพสต์', style: GoogleFonts.mali()),
              onTap: () {
                Navigator.pop(modalContext); // ปิดเมนูตัวเลือก
                _showEditPostModal(postObj); // เปิดหน้าต่างแก้ไข
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                'ลบโพสต์',
                style: GoogleFonts.mali(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(modalContext);
                await deletePost(postID);
                if (!mounted) return;
                await fetchPost();
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
            stateEdit: false,
            onPost: () {
              fetchPost();
            },
          ),
        );
      },
    );
  }

  // ============== ▼▼▼ ฟังก์ชันใหม่สำหรับเปิด Modal "แก้ไข" ▼▼▼ ==============
  void _showEditPostModal(Map<String, dynamic> postOBJ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: FullScreenPostCreator(
            stateEdit: true,
            postObj: postOBJ,
            onPost: () {
              fetchPost();
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: post.length + 2,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return PostCreationTrigger(
                        onTap: _showCreatePostModal,
                      ); // widget สร้างโพส
                    }
                    if (index == post.length + 1) {
                      return isLoadingMore
                          ? SpinKitCircle(color: Color(0xFF78B465), size: 100.0)
                          : const SizedBox.shrink();
                    }
                    final postObj = post[index - 1];
                    return UserPostCard(
                      key: ValueKey(postObj['_id']),
                      post: postObj,
                      onMoreOptionsPressed: () => _showPostOptions(postObj),
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
