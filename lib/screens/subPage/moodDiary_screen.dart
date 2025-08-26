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

class Mood {
  final Widget icon;
  final String value;
  final Color color;
  Mood({required this.icon, required this.value, required this.color});
}

class MoodDiaryScreen extends StatefulWidget {
  const MoodDiaryScreen({super.key});

  @override
  State<MoodDiaryScreen> createState() => _MoodDiaryScreenState();
}

class _MoodDiaryScreenState extends State<MoodDiaryScreen> {
  final TextEditingController _moodController =
      TextEditingController(); // ตัวเก็บค่า Value Mood

  bool isLoading = false;
  late final PageController _pageController;
  int _selectedMoodIndex = 3;
  String _selectedMoodText = "เฉยๆ";
  final List<Mood> _moods = [
    Mood(
      value: 'ประหลาดใจ',
      color: const Color(0xFFF29C41),
      icon: SizedBox(
        width: 150,
        height: 150,
        child: RiveAnimation.asset(
          'assets/animations/rives/mood.riv',
          animations: ['Wow'],
        ),
      ),
    ),
    Mood(
      value: 'มีความรัก',
      color: const Color(0xFFFF9B9B),
      icon: SizedBox(
        width: 150,
        height: 150,
        child: RiveAnimation.asset(
          'assets/animations/rives/mood.riv',
          animations: ['Love'],
        ),
      ),
    ),
    Mood(
      value: 'มีความสุข',
      color: const Color(0xFFFFCC00),
      icon: SizedBox(
        width: 150,
        height: 150,
        child: RiveAnimation.asset(
          'assets/animations/rives/mood.riv',
          animations: ['Happy'],
        ),
      ),
    ),
    Mood(
      value: 'เฉยๆ',
      color: const Color(0xFF878787),
      icon: SizedBox(
        width: 150,
        height: 150,
        child: RiveAnimation.asset(
          'assets/animations/rives/mood.riv',
          animations: ['Normal'],
        ),
      ),
    ),
    Mood(
      value: 'เศร้า',
      color: const Color(0xFF86AFFC),
      icon: SizedBox(
        width: 150,
        height: 150,
        child: RiveAnimation.asset(
          'assets/animations/rives/mood.riv',
          animations: ['Sad'],
        ),
      ),
    ),
    Mood(
      value: 'กลัว',
      color: const Color(0xFFCB9DF0),
      icon: SizedBox(
        width: 150,
        height: 150,
        child: RiveAnimation.asset(
          'assets/animations/rives/mood.riv',
          animations: ['Scare'],
        ),
      ),
    ),
    Mood(
      value: 'โกธร',
      color: const Color(0xFFEB4343),
      icon: SizedBox(
        width: 150,
        height: 150,
        child: RiveAnimation.asset(
          'assets/animations/rives/mood.riv',
          animations: ['Angry'],
        ),
      ),
    ),
  ];
  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _selectedMoodIndex,
      viewportFraction: 0.7,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    setState(() {
      isLoading = true;
    });

    String? token = await getJWTToken();
    String? userId = await getUserId();
    if (userId != null) {
      final selectedMood = _moods[_selectedMoodIndex].value;
      final text =
          _moodController.text.trim().isEmpty
              ? "ไม่มีบันทึก"
              : _moodController.text;
      final data = await addDiaryMood(token, selectedMood, text);

          
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
          'บันทึกอารมณ์',
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                // --- 1. หัวข้อ "วันนี้รู้สึกยังไงบ้าง ?" ---
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(width: 1, color: Color(0xFFE0E0E0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    'วันนี้รู้สึกยังไงบ้าง ?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.mali(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF78B465),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                // --- 2. ส่วนเลื่อนเลือกอารมณ์ (PageView) ---
                SizedBox(
                  height:
                      MediaQuery.of(context).size.height *
                      0.4, //ความสูง card Mood
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _moods.length,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedMoodIndex = index;
                        _selectedMoodText = _moods[index].value;
                      });
                    },
                    itemBuilder: (context, index) {
                      return MoodCard(
                        mood: _moods[index],
                        isSelected: index == _selectedMoodIndex,
                      );
                    },
                  ),
                ),
                const SizedBox(height:20),
                Text(
                  _selectedMoodText,
                  style: GoogleFonts.mali(
                    color: _moods[_selectedMoodIndex].color,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 30),

                FractionallySizedBox(
                  widthFactor: 0.9,
                  child: TextFormField(
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    maxLength: 100,
                    controller: _moodController,
                    decoration: InputDecoration(
                      hintText: "เขียนบันทึกได้น้า",
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
                  ),
                ),

                const SizedBox(height: 20),

                // --- 3. ปุ่มบันทึก ---
                FractionallySizedBox(
                  widthFactor: 0.90,
                  child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                await _saveMood();
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 3. Custom Widgets: แก้ไขส่วนที่แสดง Text

class MoodCard extends StatelessWidget {
  final Mood mood;
  final bool isSelected;
  const MoodCard({super.key, required this.mood, required this.isSelected});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: isSelected ? 0 : 30,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: mood.color,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: mood.color, width: 5),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: mood.color.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          mood.icon,
        ],
      ),
    );
  }
}
