import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart'; 



class Mood {
  final Widget icon;
  final String label;
  final Color color;
  Mood({required this.icon, required this.label, required this.color});
}


class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  
  late final PageController _pageController;
  int _selectedMoodIndex = 1;
  final List<Mood> _moods = [
    Mood(label: 'มีความสุข', color: const Color(0xFFBDE9C1), icon: const MoodIcon(color: Color(0xFFD4F3D7), face: '^_^')),
    Mood(label: 'เฉยๆ', color: const Color(0xFFD9CFFC), icon: const MoodIcon(color: Color(0xFFC4B2F9), face: '-_-')),
    Mood(label: 'เศร้า', color: const Color(0xFFB1EDF4), icon: const MoodIcon(color: Color(0xFFC2F1F8), face: 'T_T')),
    Mood(label: 'โกรธ', color: const Color(0xFFFFD1D1), icon: const MoodIcon(color: Color(0xFFFFBDBD), face: '>_<')),
  ];
  @override
  void initState() { super.initState(); _pageController = PageController(initialPage: _selectedMoodIndex, viewportFraction: 0.7); }
  @override
  void dispose() { _pageController.dispose(); super.dispose(); }
  void _saveMood() { final selectedMood = _moods[_selectedMoodIndex]; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('บันทึกอารมณ์: ${selectedMood.label} เรียบร้อยแล้ว', style: GoogleFonts.mali()), backgroundColor: selectedMood.color)); print('Saving mood: ${selectedMood.label}'); }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // --- 1. หัวข้อ "วันนี้รู้สึกยังไงบ้าง ?" ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text( 
                'วันนี้รู้สึกยังไงบ้าง ?',
                style: GoogleFonts.mali(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF78B465),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // --- 2. ส่วนเลื่อนเลือกอารมณ์ (PageView) ---
            SizedBox(
              height: 280,
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
            ElevatedButton(
              onPressed: _saveMood,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
              child: Text( 
                'บันทึก',
                style: GoogleFonts.mali(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF78B465),
                ),
              ),
            ),
            const Spacer(),

            // --- 4. การ์ดสถิติรายเดือน ---
            const StatisticsCard(
              consecutiveDays: 2,
              missedDays: 4,
              yesterdayMoodIcon: MoodIcon(
                color: Color(0xFFC4B2F9),
                face: '-_-',
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
          ],
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
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: isSelected ? 0 : 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: isSelected ? mood.color : Colors.transparent, width: 3), boxShadow: [if (isSelected) BoxShadow(color: mood.color.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          mood.icon,
          const Spacer(),
          Text( 
            mood.label,
            style: GoogleFonts.mali(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: mood.color.withBlue(100).withGreen(50),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class MoodIcon extends StatelessWidget {
  final Color color; final String face; final double size;
  const MoodIcon({super.key, required this.color, required this.face, this.size = 100});
  @override Widget build(BuildContext context) { return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Center(child: Text(face, style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9))))); }
}

class StatisticsCard extends StatelessWidget {
  final int consecutiveDays;
  final int missedDays;
  final Widget yesterdayMoodIcon;
  const StatisticsCard({super.key, required this.consecutiveDays, required this.missedDays, required this.yesterdayMoodIcon});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF7FBF7), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD4E9D7), width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text( 
            'สถิติรายเดือน',
            style: GoogleFonts.mali(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5A8E61),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatItem(value: consecutiveDays.toString(), label: 'วันต่อเนื่อง'),
              StatItem(value: missedDays.toString(), label: 'วันที่ไม่ได้บันทึก'),
              StatItem(customChild: yesterdayMoodIcon, label: 'อารมณ์เมื่อวาน'),
            ],
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String? value;
  final String label;
  final Widget? customChild;
  const StatItem({super.key, this.value, required this.label, this.customChild});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        customChild ??
            Text( 
              value!,
              style: GoogleFonts.mali(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
        const SizedBox(height: 5),
        Text( 
          label,
          style: GoogleFonts.mali(
            fontSize: 12,
            color: Colors.grey
          ),
        ),
      ],
    );
  }
}