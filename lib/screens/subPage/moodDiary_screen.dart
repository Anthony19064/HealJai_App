import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/diaryFeture.dart';
import 'package:healjai_project/service/token.dart';
import 'package:lottie/lottie.dart';
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
  bool isLoading = false;
  late final PageController _pageController;
  int _selectedMoodIndex = 3;
  final List<Mood> _moods = [
    Mood(
      value: 'ประหลาดใจ',
      color: const Color(0xFFE89352),
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
      color: const Color(0xFFFFD966),
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
      value: 'โกรธ',
      color: const Color(0xFFFF7B7C),
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

  void _saveMood() async {
    setState(() {
      isLoading = true;
    });
    String? token = await getJWTToken();
    String? userId = await getUserId();

    if (userId != null) {
      final selectedMood = _moods[_selectedMoodIndex].value;
      final data = await addDiaryMood(token, selectedMood);

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
              SizedBox(height: MediaQuery.of(context).size.height * 0.06),
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
              const SizedBox(height: 40),

              // --- 3. ปุ่มบันทึก ---
              FractionallySizedBox(
                widthFactor: 0.90,
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: isLoading? null : _saveMood,
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

              // --- 4. การ์ดสถิติรายเดือน ---
              // const StatisticsCard(
              //   consecutiveDays: 2,
              //   missedDays: 4,
              //   yesterdayMoodIcon: MoodIcon(
              //     color: Color(0xFFC4B2F9),
              //     face: '-_-',
              //     size: 40,
              //   ),
              // ),
            ],
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
        color: Colors.white,
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
          SizedBox(height: 20),
          Text(
            mood.value,
            style: GoogleFonts.mali(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: isSelected ? mood.color : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

// class StatisticsCard extends StatelessWidget {
//   final int consecutiveDays;
//   final int missedDays;
//   final Widget yesterdayMoodIcon;
//   const StatisticsCard({
//     super.key,
//     required this.consecutiveDays,
//     required this.missedDays,
//     required this.yesterdayMoodIcon,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF7FBF7),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xFFD4E9D7), width: 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'สถิติรายเดือน',
//             style: GoogleFonts.mali(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF5A8E61),
//             ),
//           ),
//           const SizedBox(height: 15),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               StatItem(
//                 value: consecutiveDays.toString(),
//                 label: 'วันต่อเนื่อง',
//               ),
//               StatItem(
//                 value: missedDays.toString(),
//                 label: 'วันที่ไม่ได้บันทึก',
//               ),
//               StatItem(customChild: yesterdayMoodIcon, label: 'อารมณ์เมื่อวาน'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class StatItem extends StatelessWidget {
//   final String? value;
//   final String label;
//   final Widget? customChild;
//   const StatItem({
//     super.key,
//     this.value,
//     required this.label,
//     this.customChild,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         customChild ??
//             Text(
//               value!,
//               style: GoogleFonts.mali(
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black54,
//               ),
//             ),
//         const SizedBox(height: 5),
//         Text(label, style: GoogleFonts.mali(fontSize: 12, color: Colors.grey)),
//       ],
//     );
//   }
// }
