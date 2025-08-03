import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';
import '../Widgets/bottom_nav.dart'; 

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  static const Color _moonColor = Color(0xFFC0E0FF);
  static const Color _sunColor = Color(0xFFFFA500);
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
      () {
        print('จับคู่บทบาทพระจันทร์!');
      },
      () {
        print('จับคู่บทบาทพระอาทิตย์!');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dynamicBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'แชทกับผู้ใช้',
          style: GoogleFonts.mali(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _dynamicColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
                border: Border.all(color: _dynamicColor.withOpacity(0.5), width: 1.5),
              ),
              child: Text(
                'เลือกบทบาทของคุณ :)',
                style: GoogleFonts.mali(
                  fontSize: 18,
                  color: _dynamicColor,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildRolePage(
                  roleName: 'พระจันทร์',
                  description: 'พระจันทร์คือเพื่อนเล่าเรื่องของพระอาทิตย์ ทุกครั้งที่พระจันทร์มีเรื่องไม่สบายใจ หรืออยากปรึกษาอะไรอีกอย่าง พระจันทร์มักจะมาเล่าให้พระอาทิตย์ฟังเสมอ เพราะพระอาทิตย์คือเซฟโซนให้พระจันทร์เสมอมา',
                  imagePath: 'assets/images/moon.png',
                  bgColor: _moonBgColor,
                  color: _moonColor,
                ),
                _buildRolePage(
                  roleName: 'พระอาทิตย์',
                  description: 'พระอาทิตย์คือเพื่อนรับฟังของพระจันทร์เสมอมา พระอาทิตย์มักจะรับฟังเรื่องราวของพระจันทร์อย่างเข้าใจ ไม่ว่าจะเป็นเรื่องที่ดีหรือไม่ดี พระอาทิตย์ก็จะไม่ตัดสินว่าพระจันทร์ถูกหรือผิด เพราะพระอาทิตย์คือเซฟโซนของพระจันทร์เสมอมา',
                  imagePath: 'assets/images/sun.png',
                  bgColor: _sunBgColor,
                  color: _sunColor,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),

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
          
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onMatchPressedCallbacks[_currentPage],
                style: ElevatedButton.styleFrom(
                  backgroundColor: _dynamicColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'จับคู่',
                  style: GoogleFonts.mali(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: [
          Image.asset(
            imagePath,
            height: 250,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),
          Text(
            roleName,
            style: GoogleFonts.mali(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.mali(
              fontSize: 16,
              color: const Color(0xFF464646),
            ),
          ),
        ],
      ),
    );
  }
}