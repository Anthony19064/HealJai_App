// ==============  อัปเกรด FullScreenPostCreator  ==============
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/Widgets/community/commuClass.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/commu.dart';
import 'package:image_picker/image_picker.dart';

const Color kTextColor = Color(0xFF333333);

class FullScreenPostCreator extends StatefulWidget {
  final Function() onPost;
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

  Future<void> _handlePost() async {
    final String userId = await getUserId();
    if (!_canPost) return;
    final urlIMG = await uploadImage(_selectedImage);
    final data = await addPost(userId, _controller.text, urlIMG);
    final newPost = data?['data'];
    print(data?['message']);
    widget.onPost(); // สร้างโพสให้หน้าบ้าน
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(color: Color(0xFFFFF7EB)),
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
              style: GoogleFonts.mali(color: kTextColor),
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
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed:
                                () => setState(() {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 8.0,
                          ),
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
