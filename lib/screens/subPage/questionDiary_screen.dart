import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/providers/DiaryProvider.dart';
import 'package:healjai_project/providers/TreeProvider.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/diaryFeture.dart';
import 'package:healjai_project/service/token.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'dart:math';

class QuestionDiary extends StatefulWidget {
  const QuestionDiary({super.key});

  @override
  State<QuestionDiary> createState() => _QuestionDiaryState();
}

class _QuestionDiaryState extends State<QuestionDiary> {
  bool isLoading = false;
  final _questionFormKey = GlobalKey<FormState>(); // key ของ Form
  final TextEditingController _questionController =
      TextEditingController(); // ตัวเก็บค่า Value Question

  final List<String> questionList = [
    "ถ้าให้เลือกสีสำหรับวันนี้\nเธอจะเลือกสีอะไรหรอ ?",
    "เรื่องที่ทำให้มีความสุขมาก\nที่สุดในวันนี้ คือเรื่องอะไรหรอ ?",
    "สิ่งเล็กๆที่ชอบมากที่สุดในวันนี้",
    "ถ้าอธิบายวันนี้ด้วยอิโมจิเดียว\nจะเลือกอิโมจิอะไร",
    "สถานที่ที่เธออยากไปที่สุดในตอนนี้\nคือที่ไหนหรอ ?",
    "วันนี้อยากขอบคุณตัวเองเรื่องอะไร",
    "เมนูอาหารที่อยากกินในวันพรุ่งนี้",
    "เรื่องที่ไม่ชอบในวันนี้\nคือเรื่องอะไรหรอ ?",
    "คำพูดไหนในวันนี้ที่ได้ยิน\nแล้วทำให้ยิ้มได้",
    "อะไรที่อยากบอกกับตัวเอง\nในตอนเช้าของวันนี้",
    "ถ้าขอพรได้ 1 อย่างสำหรับวันนี้\nเธอจะขออะไรหรอ ?",
    "ถ้าอารมณ์เธอวันนี้เป็นสภาพอากาศ\nจะเป็นยังไงหรอ ?",
  ];

  String getRandomQuestion() {
    final random = Random();
    int index = random.nextInt(questionList.length);
    return questionList[index];
  }

  late String question; // ตัวแปรเก็บคำถาม

  @override
  void initState() {
    super.initState();
    question = getRandomQuestion();
  }

  Future<void> SaveQuestion() async {
    setState(() {
      isLoading = true;
    });
    String? token = await getJWTAcessToken();
    String? userId = await getUserId();

    if (userId != null) {
      final answer = _questionController.text;
      final data = await addDiaryQuestion(token, question, answer);
      setState(() {
        isLoading = false;
      });
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

    await Provider.of<DiaryProvider>(context, listen: false).fetchTaskCount();
    await Provider.of<TreeProvider>(context, listen: false).fetchTreeAge();
    await Future.delayed(Duration(seconds: 1));
    context.pop();
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
          'คำถามประจำวัน',
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
                      question, // สุ่มคำถาม
                      textAlign: TextAlign.center,
                      style: GoogleFonts.mali(
                        color: Color(0xFF464646),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 2,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: RiveAnimation.asset(
                        "assets/animations/rives/goose_question.riv",
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                    Form(
                      key: _questionFormKey,
                      child: TextFormField(
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        maxLength: 100,
                        controller: _questionController,
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : () async {
                                  if (_questionFormKey.currentState!
                                      .validate()) {
                                    await SaveQuestion();
                                    _questionController.clear();
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
                                : Text(
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
                    // SizedBox(height: 30,)
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
