import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:healjai_project/Widgets/bottom_nav.dart';
import 'package:healjai_project/Widgets/header_section.dart';


// หน้าสำหรับดูรูปภาพ
class PhotoViewScreen extends StatelessWidget {
  final String imagePath;

  const PhotoViewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(color: const Color(0xFFFFF7EB)),
          ),
          PhotoView(
            imageProvider: FileImage(File(imagePath)),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.0,
            heroAttributes: PhotoViewHeroAttributes(tag: imagePath),
            backgroundDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

class Comment {
  final String username;
  final String avatarUrl;
  final String text;

  Comment({
    required this.username,
    required this.avatarUrl,
    required this.text,
  });
}

class Post {
  final String id;
  final String username;
  final String avatarUrl;
  final String timeAgo;
  String postText;
  int likes;
  bool isLiked;
  List<Comment> comments;
  int reposts;
  String? imageUrl;

  Post({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.timeAgo,
    required this.postText,
    this.likes = 0,
    this.isLiked = false,
    List<Comment>? comments,
    this.reposts = 0,
    this.imageUrl,
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

  void _showCommentDialog(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) {
        return _CommentsDialog(
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
      body: SafeArea(
        child: Column(
          children: [
            const HeaderSection(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                itemCount: _posts.length + 1,
                separatorBuilder: (context, index) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return PostCreationTrigger(
                      onTap: _showCreatePostModal,
                    );
                  }
                  final post = _posts[index - 1];
                  return UserPostCard(
                    post: post,
                    onLikePressed: () => _toggleLike(post.id),
                    onCommentPressed: () => _showCommentDialog(post),
                    onMoreOptionsPressed: () => _showPostOptions(post),
                    onRepostPressed: () => _incrementReposts(post.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostCreationTrigger extends StatelessWidget {
  final VoidCallback onTap;

  const PostCreationTrigger({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
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
    );
  }
}

// ==============  อัปเกรด FullScreenPostCreator  ==============
class FullScreenPostCreator extends StatefulWidget {
  final Function(String text, String? imagePath) onPost;
  final Post? postToEdit; 

  const FullScreenPostCreator({
    super.key, 
    required this.onPost, 
    this.postToEdit, 
  });

  @override
  State<FullScreenPostCreator> createState() => _FullScreenPostCreatorState();
}

class _FullScreenPostCreatorState extends State<FullScreenPostCreator> {
  final _controller = TextEditingController();
  File? _selectedImage;
  bool _canPost = false;

  @override
  void initState() {
    super.initState();
    // ตรวจสอบว่ามี postToEdit ถูกส่งมาหรือไม่ (เป็นโหมดแก้ไข)
    if (widget.postToEdit != null) {
      // ถ้าใช่, ให้กำหนดค่าเริ่มต้นให้ text และ รูปภาพ
      _controller.text = widget.postToEdit!.postText;
      if (widget.postToEdit!.imageUrl != null) {
        _selectedImage = File(widget.postToEdit!.imageUrl!);
      }
    }

    // listener ตัวเดิมใช้ได้เลย
    _controller.addListener(() {
      setState(() {
        _canPost = _controller.text.isNotEmpty || _selectedImage != null;
      });
    });
    // เช็คสถานะปุ่มโพสต์ครั้งแรก
    _canPost = _controller.text.isNotEmpty || _selectedImage != null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _canPost = true;
      });
    }
  }

  void _handlePost() {
    if (!_canPost) return;
    widget.onPost(_controller.text, _selectedImage?.path);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF7EB),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black54),
              onPressed: () => Navigator.pop(context),
            ),
            // เปลี่ยนหัวข้อตามโหมด (สร้าง/แก้ไข)
            title: Text(
              widget.postToEdit == null ? 'สร้างโพสต์ใหม่' : 'แก้ไขโพสต์',
              style: GoogleFonts.mali(color: kTextColor)
            ),
            actions: [
              TextButton(
                onPressed: _canPost ? _handlePost : null,
                child: Text(
                  'โพสต์',
                  style: GoogleFonts.mali(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _canPost ? const Color(0xFF78B465) : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  autofocus: true,
                  style: GoogleFonts.mali(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'วันนี้มีเรื่องราวอะไรมาแบ่งปันบ้าง...',
                    hintStyle: GoogleFonts.mali(),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 20),
                if (_selectedImage != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            onPressed: () => setState(() {
                              _selectedImage = null;
                              _canPost = _controller.text.isNotEmpty;
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 1.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                color: const Color(0xFF78B465),
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'รูปภาพ',
                                style: GoogleFonts.mali(
                                  color: const Color(0xFF78B465),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _CommentsDialog extends StatefulWidget {
  final Post post;
  final VoidCallback onCommentAdded;

  const _CommentsDialog({required this.post, required this.onCommentAdded});

  @override
  State<_CommentsDialog> createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<_CommentsDialog> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (_commentController.text.isNotEmpty) {
      final newComment = Comment(
        username: 'Me',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        text: _commentController.text,
      );

      setState(() {
        widget.post.comments.add(newComment);
      });
      widget.onCommentAdded();
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: 500,
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF7EB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(62, 0, 0, 0),
              blurRadius: 20,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ความคิดเห็น',
                  style: GoogleFonts.mali(
                    color: const Color(0xFF78B465),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: widget.post.comments.isEmpty
                  ? Center(
                      child: Text(
                        'ยังไม่มีความคิดเห็น',
                        style: GoogleFonts.mali(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.post.comments.length,
                      itemBuilder: (context, index) {
                        final comment = widget.post.comments[index];
                        final cardColor = index.isEven ? Colors.white : const Color(0xFFF1F8E9);

                        return Card(
                          color: cardColor,
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    comment.avatarUrl,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment.username,
                                        style: GoogleFonts.mali(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment.text,
                                        style: GoogleFonts.mali(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              autofocus: true,
              style: GoogleFonts.mali(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "แสดงความคิดเห็นของคุณ...",
                hintStyle: GoogleFonts.mali(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF78B465)),
                  onPressed: _submitComment,
                ),
              ),
              onSubmitted: (_) => _submitComment(),
            ),
          ],
        ),
      ),
    );
  }
}

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
    final likeBorderColor = post.isLiked ? Colors.red.shade200 : kLikeButtonBorderColor;
    final likeBackgroundColor = post.isLiked ? Colors.red.shade50 : kLikeButtonBackgroundColor;

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
                      builder: (context) => PhotoViewScreen(imagePath: post.imageUrl!),
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
    );
  }
}

class InteractionButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final Color borderColor;
  final Color backgroundColor;
  const InteractionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.borderColor,
    required this.backgroundColor,
    this.iconColor,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor ?? kIconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.mali(
              color: kIconColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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