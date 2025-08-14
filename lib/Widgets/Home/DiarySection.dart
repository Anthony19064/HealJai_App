import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DiarySection extends StatefulWidget {
  const DiarySection({super.key});

  @override
  State<DiarySection> createState() => _DiarySectionState();
}

class _DiarySectionState extends State<DiarySection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Text(
            "ภารกิจประจำวัน",
            style: GoogleFonts.mali(
              fontSize: 22,
              color: Color(0xFF78B465),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Activity(
                  ActivityIcon: "assets/icons/MoodIcon.svg",
                  ActivityName: "อารมณ์",
                  ActivityPress: () {
                    context.go('/mood-tracker');
                    print("อารมณ์");
                  },
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                flex: 3,
                child: Activity(
                  ActivityIcon: "assets/icons/QuestionIcon.svg",
                  ActivityName: "คำถาม",
                  ActivityPress: () {
                    print("คำถาม");
                  },
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                flex: 3,
                child: Activity(
                  ActivityIcon: "assets/icons/LifeIcon.svg",
                  ActivityName: "เรื่องราว",
                  ActivityPress: () {
                    print("เรื่องราว");
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          DiaryTask(),
          SizedBox(height: 100,)
        ],
      ),
    );
  }
}

class Activity extends StatefulWidget {
  final String ActivityIcon;
  final String ActivityName;
  final VoidCallback ActivityPress;

  const Activity({
    required this.ActivityIcon,
    required this.ActivityName,
    required this.ActivityPress,
    super.key,
  });

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.ActivityPress,
      child: Container(
        height: 110,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(width: 1, color: Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              spreadRadius: 0,
              blurRadius: 4,
              offset: Offset(0, 2), // เงาด้านล่าง
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: SvgPicture.asset(
                  widget.ActivityIcon,
                  color: Color(0xFF78B465),
                ),
              ),
              SizedBox(width: 20),
              Text(
                widget.ActivityName,
                style: GoogleFonts.mali(
                  fontSize: 16,
                  color: Color(0xFF78B465),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiaryTask extends StatefulWidget {
  const DiaryTask({super.key});

  @override
  State<DiaryTask> createState() => _DiaryTaskState();
}

class _DiaryTaskState extends State<DiaryTask> {
  double taskPercent = 0;
  int taskCount = 0;
  int totalTask = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 2, color: Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            "ความคืบหน้าประจำวัน",
            style: GoogleFonts.mali(
              color: Color(0xFF78B465),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 20),
          FractionallySizedBox(
            widthFactor: 0.95,
            child: Container(
              child: LinearPercentIndicator(
                lineHeight: 30.0,
                percent: taskPercent,
                backgroundColor: Colors.grey.shade300,
                progressColor: Color(0xFF78B465),
                center: Text(
                  "${taskCount}/3",
                  style: GoogleFonts.mali(
                    color: Color(0xFF464646),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                animation: true,
                animationDuration: 500,
                barRadius: Radius.circular(20),
              ),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: 100,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // ปรับขอบมนตรงนี้
                ),
                backgroundColor: Color(0xFF78B465),
              ),
              onPressed: () {
                // โค้ดทดลองเพิ่มค่าหลอด Progress
                // setState(() {
                //   if (taskCount < totalTask) {
                //     taskCount += 1;
                //     taskPercent = taskCount / totalTask;
                //   }
                // });
              },
              child: Text(
                "รับ",
                style: GoogleFonts.mali(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
