import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:healjai_project/Widgets/bottom_nav.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  static const Color _moonColor = Color(0xFF7FD8EB);
  static const Color _sunColor = Color(0xFFFE9526);
  static const Color _moonBgColor = Color(0xFFFFF7EB);
  static const Color _sunBgColor = Color(0xFFFFF7EB);

  Color get _dynamicColor => _currentPage == 0 ? _moonColor : _sunColor;
  Color get _dynamicBgColor => _currentPage == 0 ? _moonBgColor : _sunBgColor;
  String get _roleName => _currentPage == 0 ? 'พระจันทร์' : 'พระอาทิตย์';

  late final List<VoidCallback> _onMatchPressedCallbacks;

  @override
  void initState() {
    super.initState();
    _onMatchPressedCallbacks = [
      () async {
        _showLoadingDialog(); // <<-- เรียกใช้เมธอดใหม่
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pop();
        context.go('/chat/room/moon');
      },
      () async {
        _showLoadingDialog(); // <<-- เรียกใช้เมธอดใหม่
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pop();
        context.go('/chat/room/sun');
      },
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  // **<<--- เพิ่มเมธอดใหม่สำหรับแสดง Loading dialog**
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // **<<--- แก้ไข: เปลี่ยนสีของ CircularProgressIndicator**
                CircularProgressIndicator(color: _dynamicColor),
                const SizedBox(height: 20),
                Text(
                  'กำลังจับคู่...',
                  style: GoogleFonts.mali(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    // **<<--- แก้ไข: เปลี่ยนสีของข้อความ**
                    color: _dynamicColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dynamicBgColor,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              ZoomIn(
                duration: Duration(milliseconds: 500),
                child: Column(
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 300),
                      style: GoogleFonts.mali(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _dynamicColor,
                      ),
                      child: Text('แชทกับผู้ใช้'),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.030,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.055,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.0),
                        border: Border.all(
                          color: Color(0xFFE0E0E0).withOpacity(0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 300),
                        style: GoogleFonts.mali(
                          fontSize: 18,
                          color: _dynamicColor,
                          fontWeight: FontWeight.w700,
                        ),
                        child: Text('เลือกบทบาทของคุณ :)'),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    _buildRolePage(
                      roleName: 'พระจันทร์',
                      description:
                          'พระจันทร์คือเพื่อนเล่าเรื่องของพระอาทิตย์ ทุกครั้งที่พระจันทร์มีเรื่องไม่สบายใจ หรืออยากปรึกษาอะไรอีกอย่าง พระจันทร์มักจะมาเล่าให้พระอาทิตย์ฟังเสมอ เพราะพระอาทิตย์คือเซฟโซนให้พระจันทร์เสมอมา',
                      imagePath: 'assets/images/moon.png',
                      bgColor: _moonBgColor,
                      color: _dynamicColor,
                    ),
                    _buildRolePage(
                      roleName: 'พระอาทิตย์',
                      description:
                          'พระอาทิตย์คือเพื่อนรับฟังของพระจันทร์เสมอมา พระอาทิตย์รับฟังเรื่องราวของพระจันทร์อย่างเข้าใจ พระอาทิตย์ก็จะไม่ตัดสินว่าพระจันทร์ถูกหรือผิด เพราะพระอาทิตย์คือเซฟโซนของพระจันทร์เสมอมา',
                      imagePath: 'assets/images/sun.png',
                      bgColor: _sunBgColor,
                      color: _dynamicColor,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              ZoomIn(
                duration: Duration(milliseconds: 500),
                child: Column(
                  children: [
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: 2,
                      effect: WormEffect(
                        dotHeight: 10,
                        dotWidth: 10,
                        activeDotColor: _dynamicColor,
                        dotColor: _dynamicColor.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: GestureDetector(
                        onTap: _onMatchPressedCallbacks[_currentPage],
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: 100,
                          height: 45,
                          decoration: BoxDecoration(
                            color: _dynamicColor,
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Center(
                            child: Text(
                              'จับคู่',
                              style: GoogleFonts.mali(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildRolePage({
    required String roleName,
    required String description,
    required String imagePath,
    required Color bgColor,
    required Color color,
  }) {
    return ZoomIn(
      duration: Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width * 0.5,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 300),
              style: GoogleFonts.mali(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),

              child: Text(roleName),
            ),
            const SizedBox(height: 30),
            Text(
              "   $description",
              textAlign: TextAlign.left,

              style: GoogleFonts.mali(
                fontSize: 15,
                color: const Color(0xFF464646),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
                height: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
