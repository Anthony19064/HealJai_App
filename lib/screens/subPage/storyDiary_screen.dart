import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/diaryFeture.dart';
import 'package:healjai_project/service/token.dart';
import 'package:lottie/lottie.dart';

//------ List เก็บข้อมูล
List<String> _storyList = [];

// ------------- Class โชว์ Ui หลัก -----------------
class StoryDiary extends StatefulWidget {
  const StoryDiary({super.key});

  @override
  State<StoryDiary> createState() => _StoryDiaryState();
}

class _StoryDiaryState extends State<StoryDiary> {
  bool isLoading = false;
  final _storyFormKey = GlobalKey<FormState>(); // key ของ Form
  final TextEditingController _storyController =
      TextEditingController(); // ตัวเก็บค่า Value Question

  void _addStory(String info) {
    setState(() {
      _storyList.add(info);
    });
  }

  void _deleteStory(int index) {
    setState(() {
      _storyList.removeAt(index);
    });
  }

  Future<void> saveStory() async {
    setState(() {
      isLoading = true;
    });
    String? token = await getJWTToken();
    String? userId = await getUserId();

    if (userId != null) {
      final data = await addDiaryStory(token, _storyList);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              '${data['message']}',
              textAlign: TextAlign.center,
              style: GoogleFonts.mali(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          backgroundColor:
              data['success'] == true ? Color(0xFF78B465) : Color(0xFFFD7D7E),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'ต้องล็อคอินก่อนนะ :(',
              textAlign: TextAlign.center,
              style: GoogleFonts.mali(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          backgroundColor: Color(0xFFFD7D7E),
        ),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _storyList = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFF7EB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          'บันทึกเรื่องราวดีๆ',
          style: GoogleFonts.mali(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF78B465),
          ),
        ),
        centerTitle: true,
      ),
      body: ZoomIn(
        duration: Duration(milliseconds: 500),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                    Text(
                      "วันนี้มีเรื่องราวอะไรดีๆ ที่เธอชอบบ้างในวันนี้",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.mali(
                        fontSize: 15,
                        color: Color(0xFF464646),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.vibrate();
                        showAddStory(
                          context,
                          _storyFormKey,
                          _storyController,
                          _addStory,
                        );
                      },

                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          dashPattern: [10, 5],
                          strokeWidth: 2,
                          color: Color(0xFF78B465),
                          radius: Radius.circular(16),
                        ),
                        child: Container(
                          height: 65,
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: SvgPicture.asset(
                                  "assets/icons/add.svg",
                                  color: Color(0xFF78B465),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "เพิ่มเรื่องราว",
                                style: GoogleFonts.mali(
                                  fontSize: 23,
                                  color: Color(0xFF78B465),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Text(
                      "กดค้างเพื่อลบได้นะ :)",
                      style: GoogleFonts.mali(
                        fontSize: 12,
                        color: Color(0xFFA1A1A1),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _storyList.length,
                      itemBuilder: (context, index) {
                        return StoryCard(
                          indexStory: index,
                          info: _storyList[index],
                          onDelete: _deleteStory,
                        );
                      },
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : () async{
                                  if (_storyList.length != 0) {
                                    await saveStory();
                                    _storyList.clear();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 10,
                                          ),
                                          child: Text(
                                            "ต้องเพิ่มเรื่องราวก่อนน้า",
                                            style: GoogleFonts.mali(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        backgroundColor: Color(0xFFFD7D7E),
                                      ),
                                    );
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF78B465),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                        ),
                        child:
                            isLoading
                                ? Transform.scale(
                                  scale: 2,
                                  child: Lottie.asset(
                                    'assets/animations/lotties/loading.json',
                                  ),
                                )
                                : Container(
                                  width: double.infinity,
                                  child: Text(
                                    'บันทึก',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.mali(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
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

//------------- Class แสดงส่วน Card -------------------------
class StoryCard extends StatefulWidget {
  final int indexStory;
  final String info;
  final Function(int) onDelete;

  const StoryCard({
    required this.indexStory,
    required this.info,
    required this.onDelete,
    super.key,
  });

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.vibrate();
        widget.onDelete(widget.indexStory);
      },
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 55),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        margin: EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(width: 2, color: Color(0xFF78B465)),
        ),
        child: Center(
          child: Text(
            '${widget.indexStory + 1}. ${widget.info}',
            softWrap: true,
            style: GoogleFonts.mali(
              fontSize: 18,
              color: Color(0xFF464646),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

void showAddStory(
  BuildContext context,
  GlobalKey<FormState> _formKey,
  TextEditingController _controller,
  Function(String) onAdd,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder:
        (_) => Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(
                  context,
                ).viewInsets.bottom, // ทำให้ bottomsheet ยืดขึ้นเวลาเปิดคีบอด
          ),
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 150,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Color(0xFFD0D0D0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 25),
                  Text(
                    "เพิ่มเรื่องราว",
                    style: GoogleFonts.mali(
                      color: Color(0xFF78B465),
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 25),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      maxLength: 100,
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "พิมพ์คำตอบที่นี่ . . . .",
                        hintStyle: GoogleFonts.mali(
                          color: Color(0xFF919191),
                          fontWeight: FontWeight.w700,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide(
                            color: Color(0xFFE0E0E0),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide(
                            color: Color(0xFFE0E0E0),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide(
                            color: Color(0xFFB3B3B3),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 20.0,
                        ),
                      ),
                      style: GoogleFonts.mali(
                        color: Color(0xFF464646),
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกคำตอบ';
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        onAdd(_controller.text);
                        Navigator.pop(context);
                        _controller.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF78B465),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        "เพิ่ม",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.mali(
                          color: Color(0xFFFFFFFF),
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
  ).whenComplete(() {
    _controller.clear(); // <-- เคลียร์ค่าที่นี่
  });
}
