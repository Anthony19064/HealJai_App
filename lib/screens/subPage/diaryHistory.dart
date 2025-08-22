import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/diaryFeture.dart';
import 'package:healjai_project/service/token.dart';
import 'package:intl/intl.dart';
import 'package:rive/rive.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flip_card/flip_card.dart';

class Diaryhistory extends StatefulWidget {
  const Diaryhistory({super.key});

  @override
  State<Diaryhistory> createState() => _DiaryhistoryState();
}

class _DiaryhistoryState extends State<Diaryhistory> {
  // GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<DateTime> _event = []; // วันที่มีการบันทึก

  List<dynamic> _moodInfo = []; // อารมณ์ของวันนั้น

  final Map<String, List<dynamic>> _moodIcon = {
    "ประหลาดใจ": ["Wow", Color(0xFFF29C41)],
    "มีความรัก": ["Love", Color(0xFFFF9B9B)],
    "มีความสุข": ["Happy", Color(0xFFFFCC00)],
    "เฉยๆ": ["Normal", Color(0xFF878787)],
    "เศร้า": ["Sad", Color(0xFF86AFFC)],
    "กลัว": ["Scare", Color(0xFFCB9DF0)],
    "โกธร": ["Angry", Color(0xFFEB4343)],
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _loadDiaryHistory();
    _loadDiaryInfo();
  }

  Future<void> _loadDiaryHistory() async {
    String? token = await getJWTToken();
    String? userId = await getUserId();

    if (userId != null) {
      int year = _focusedDay.year;
      int month = _focusedDay.month;

      List<DateTime> events = await diaryHistory(token, year, month);
      setState(() {
        _event = events;
      });
    } else {
      return;
    }
  }

  Future<void> _loadDiaryInfo() async {
    String? token = await getJWTToken();
    String? userId = await getUserId();
    if (userId != null) {
      int day = _focusedDay.day;
      int month = _focusedDay.month;
      int year = _focusedDay.year;

      final data = await diaryInfo(token, day, month, year);
      // print(data?['mood']['value']);
      if (data != null) {
        setState(() {
          _moodInfo = data['mood']['value'];
        });
      }
      else{
        setState(() {
          _moodInfo = [];
        });
      }
    } else {
      return;
    }
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                calendar(),
                const SizedBox(height: 30),
                Text(
                  "บันทึกของวันที่  ${_selectedDay?.day}",
                  style: GoogleFonts.mali(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF78B465),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 260,
                  child: PageView.builder(
                    itemCount: _moodInfo.length,
                    controller: PageController(viewportFraction: 0.8),
                    itemBuilder: (context, index) {
                      final moodColor =
                          _moodIcon[_moodInfo[index]['mood']]?[1]; //สีประจำ Mood
                      final moodAnimation =
                          _moodIcon[_moodInfo[index]['mood']]?[0]; // อนิเมชั่นของ Mood
                      final time =
                          DateTime.parse(_moodInfo[index]['time']).toLocal();
                      final timeString = DateFormat.Hm().format(time);

                      return ZoomIn(
                        duration: Duration(milliseconds: 500),
                        child: FlipCard(
                          flipOnTouch: true,
                          front: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: moodColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(width: 3, color: moodColor),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: RiveAnimation.asset(
                                    'assets/animations/rives/mood.riv',
                                    animations: [moodAnimation],
                                  ),
                                ),
                        
                                Text(
                                  _moodInfo[index]['mood'],
                                  style: GoogleFonts.mali(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          back: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: moodColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(width: 3, color: moodColor),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${timeString}',
                                  style: GoogleFonts.mali(
                                    color: Colors.white,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 30),
                                Text(
                                  _moodInfo[index]['text'],
                                  style: GoogleFonts.mali(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget calendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2025, 1, 1),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _focusedDay,
      daysOfWeekHeight: 60,
      rowHeight: 70,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (selectedDay.month != focusedDay.month) return;
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
         _loadDiaryInfo();

      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        _loadDiaryHistory();
      },
      calendarBuilders: CalendarBuilders(
        // วันปกติ
        defaultBuilder: (context, day, focusedDay) {
          final isEventDay = _event.any((d) => isSameDay(d, day));

          return Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isEventDay ? const Color(0xFFACD1AF) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${day.day}',
              style: GoogleFonts.mali(
                color: isEventDay ? Colors.white : const Color(0xFF464646),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          );
        },

        // วันปัจจุบัน
        todayBuilder: (context, day, focusedDay) {
          final isEventDay = _event.any((d) => isSameDay(d, day));

          return Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isEventDay ? const Color(0xFFACD1AF) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${day.day}',
              style: GoogleFonts.mali(
                color: isEventDay ? Colors.white : const Color(0xFF464646),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          );
        },

        // วันที่เลือก
        selectedBuilder: (context, day, focusedDay) {
          final isEventDay = _event.any((d) => isSameDay(d, day));

          return Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color:
                  isEventDay
                      ? const Color(0xFF78B465) // สีเขียวอ่อนถ้ามี event
                      : const Color(0xFF78B465), // สีเขียวเข้มถ้าไม่มี event
              shape: BoxShape.circle,
              border:
                  isEventDay
                      ? Border.all(color: const Color(0xFF78B465), width: 3)
                      : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '${day.day}',
              style: GoogleFonts.mali(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          );
        },
      ),

      calendarStyle: CalendarStyle(
        // style ของ Text วันนอกเดือน
        outsideTextStyle: GoogleFonts.mali(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Colors.grey.shade400,
        ),
      ),

      // style ของ Text ชื่อเดือนที่เลือก
      headerStyle: HeaderStyle(
        titleTextStyle: GoogleFonts.mali(
          fontWeight: FontWeight.w700,
          fontSize: 25,
          color: Color(0xFF78B465),
        ),
        formatButtonVisible: false,
        titleCentered: true,
        // ขนาดไอคอนปุ่มเปลี่ยนเดือน
        leftChevronIcon: Icon(
          Icons.chevron_left,
          size: 30,
          color: Color(0xFF464646),
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          size: 30,
          color: Color(0xFF464646),
        ),
      ),

      // style ของ Text หัวข้อวัน
      daysOfWeekStyle: DaysOfWeekStyle(
        // วันปกติ
        weekdayStyle: GoogleFonts.mali(
          color: Color(0xFF464646),
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
        // วันหยุด
        weekendStyle: GoogleFonts.mali(
          color: Color(0xFF464646),
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
      ),
    );
  }
}
