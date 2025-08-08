import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:healjai_project/Widgets/bottom_nav.dart';
import '../../service/socket.dart';
import '../../providers/chatProvider.dart';

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
  static const Color _moonBgColor = Color(0xFF0C1A28);
  static const Color _sunBgColor = Color(0xFF1D5B99);

  Color get _dynamicColor => _currentPage == 0 ? _sunColor : _moonColor;
  Color get _dynamicBgColor => _currentPage == 0 ? _sunBgColor : _moonBgColor;
  String get _roleName => _currentPage == 0 ? 'พระอาทิตย์' : 'พระจันทร์';

  late final List<VoidCallback> _onMatchPressedCallbacks;

  final socket = SocketService();
  late final Chatprovider chatProvider;

  StateMachineController? _controller;
  SMIInput<double>? _stateNumInput;

  @override
  void initState() {
    super.initState();
    chatProvider = Provider.of<Chatprovider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      socket.initSocket(context); // ทำงานหลังสร้าง Ui เสร็จ
    });

    _onMatchPressedCallbacks = [
      () async {
        // await _showLoadingDialog(); // โชว์ Dialog
        // chatProvider.setRole('talker');
        // await socket.waitUntilConnected();
        // socket.matchChat("talker");
        context.go('/chat/room/moon');
      },
      () async {
        // await _showLoadingDialog(); // โชว์ Dialog
        // chatProvider.setRole('listener');
        // await socket.waitUntilConnected();
        // socket.matchChat("listener");
        context.go('/chat/room/sun');
      },
    ];
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    socket.cancelMatch();
    chatProvider.clearRoomId(notify: false);
    chatProvider.clearRole(notify: false);
    chatProvider.clearListMessage(notify: false);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
      _stateNumInput?.value = index.toDouble();
    });
  }

  // **<<--- เพิ่มเมธอดใหม่สำหรับแสดง Loading dialog**
  Future<void> _showLoadingDialog() async {
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
            width: double.infinity,
            height: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                CircularProgressIndicator(color: _dynamicColor),
                const SizedBox(height: 60),
                Text(
                  'กำลังจับคู่ให้น้าา ...',
                  style: GoogleFonts.mali(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    // **<<--- แก้ไข: เปลี่ยนสีของข้อความ**
                    color: _dynamicColor,
                  ),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    socket.cancelMatch();
                    chatProvider.clearRole();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 200,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFFFD7D7E),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Text(
                        "ยกเลิกจับคู่",
                        style: GoogleFonts.mali(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: _dynamicBgColor),
      duration: const Duration(milliseconds: 2000),
      builder: (context, color, child) {
        return Scaffold(
          backgroundColor: color,
          body: child,
          bottomNavigationBar: const BottomNavBar(),
        );
      },
      child: SafeArea(
        child: Container(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.030),
              ZoomIn(
                duration: Duration(milliseconds: 500),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.010,
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.05), // สูง 5%
              ZoomIn(
                duration: Duration(milliseconds: 500),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: RiveAnimation.asset(
                    'assets/animations/Role.riv',
                    onInit: (artboard) {
                      final controller = StateMachineController.fromArtboard(
                        artboard,
                        'ChatHomeState',
                      );
                      if (controller != null) {
                        artboard.addController(controller);
                        _controller = controller;
                
                        _stateNumInput = controller.findInput<double>('StateNum');
                        if (_stateNumInput == null) {
                          print("❌ ไม่พบตัวแปร StateNum");
                        }
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05), // สูง 5%
              Container(
                height: 70,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    _buildRolePage(
                      roleName: 'พระอาทิตย์',
                      bgColor: _sunBgColor,
                      color: _dynamicColor,
                    ),
                    _buildRolePage(
                      roleName: 'พระจันทร์',
                      bgColor: _moonBgColor,
                      color: _dynamicColor,
                    ),
                  ],
                ),
              ),

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
    );
  }

  Widget _buildRolePage({
    required String roleName,
    required Color bgColor,
    required Color color,
  }) {
    return ZoomIn(
      duration: Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
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
          ],
        ),
      ),
    );
  }
}
