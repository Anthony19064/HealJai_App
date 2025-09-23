// ==============  อัปเกรด FullScreenPostCreator  ==============
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/badWordCheck.dart';
import 'package:healjai_project/service/commu.dart';
import 'package:image_picker/image_picker.dart';

const Color kTextColor = Color(0xFF333333);

class FullScreenPostCreator extends StatefulWidget {
  final VoidCallback onPost;
  final bool stateEdit;
  final Map<String, dynamic>? postObj;

  const FullScreenPostCreator({
    super.key,
    required this.onPost,
    required this.stateEdit,
    this.postObj,
  });

  @override
  State<FullScreenPostCreator> createState() => _FullScreenPostCreatorState();
}

class _FullScreenPostCreatorState extends State<FullScreenPostCreator> {
  final _controller = TextEditingController();
  File? _selectedImage;
  String imageURL = '';
  bool _canPost = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // ตรวจสอบว่ามี postToEdit ถูกส่งมาหรือไม่ (เป็นโหมดแก้ไข)
    if (widget.stateEdit) {
      _controller.text = widget.postObj!['infoPost'];
      imageURL = widget.postObj!['img'] ?? '';
    }
    // เช็คสถานะปุ่มโพสต์ครั้งแรก
    _canPost = _controller.text.isNotEmpty;

    // listener ตัวเดิมใช้ได้เลย
    _controller.addListener(() {
      setState(() {
        _canPost = _controller.text.isNotEmpty;
      });
    });
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
        imageURL = '';
      });
    }
  }

  Future<void> _handlePost() async {
    if (!_canPost) return;
    String textInput = _controller.text;
    final checkBadword = checkBadWord(textInput);
    if (checkBadword) {
      showErrorToast();
      return;
    }
    setState(() {
      isLoading = true;
    });
    final String userId = await getUserId();
    String? urlIMG = await uploadImage(_selectedImage);
    final data = await addPost(userId, textInput, urlIMG);
    final newPost = data?['data'];
    if (newPost != null) {
      widget.onPost(); // ส่งกลับไปที่ CommuScreen
    }
    setState(() {
      isLoading = false;
    });
    _controller.clear();
    _selectedImage = null;
    _canPost = false;
    Navigator.pop(context);
  }

  Future<void> _handleEdit() async {
    if (!_canPost) return;
    String textInput = _controller.text;
    final checkBadword = checkBadWord(textInput);
    if (checkBadword) {
      showErrorToast();
      return;
    }
    setState(() {
      isLoading = true;
    });
    String postID = widget.postObj!['_id'];
    if (imageURL.trim().isEmpty) {
      widget.postObj!['img'] = "";
    }
    if (_selectedImage != null) {
      String? newImageUrl = await uploadImage(_selectedImage);
      widget.postObj!['img'] = newImageUrl;
    }
    widget.postObj!['infoPost'] = _controller.text;
    await updatePost(postID, widget.postObj!);
    widget.onPost(); // ส่งกลับไปที่ CommuScreen
    setState(() {
      isLoading = false;
    });
    _controller.clear();
    _selectedImage = null;
    _canPost = false;
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
              widget.stateEdit ? 'แก้ไขโพสต์' : 'สร้างโพสต์',
              style: GoogleFonts.mali(color: kTextColor),
            ),
            actions: [
              IgnorePointer(
                ignoring: isLoading,
                child: TextButton(
                  onPressed: widget.stateEdit ? _handleEdit : _handlePost,
                  child: Text(
                    'โพสต์',
                    style: GoogleFonts.mali(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _canPost ? const Color(0xFF78B465) : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                Column(
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
                    if (imageURL.trim().isNotEmpty)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              imageURL,
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
                                      imageURL = '';
                                      _canPost = _controller.text.isNotEmpty;
                                    }),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (isLoading)
                  Transform.translate(
                    offset: Offset(0, MediaQuery.of(context).size.height * 0.3),
                    child: SpinKitCircle(color: Color(0xFF78B465), size: 100.0),
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
