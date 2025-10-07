import 'dart:async';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/providers/navProvider.dart';
import 'package:healjai_project/service/account.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/minigame.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class _FloatingText {
  final Key id;
  final String text;
  final Offset position;

  _FloatingText({required this.id, required this.text, required this.position});
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  Artboard? _artboard;
  OneShotAnimation? _animation;
  bool _isCooldown = false;
  int _score = 0;
  bool _isLoading = true;
  late AudioPool _chopPool;
  late AudioPool _criticalPool;
  List<dynamic> _leaderboardData = [];
  Timer? _debounceTimer;
  PageController _pageController = PageController();
  int currentPage = 0;
  bool isMuted = true;
  final player = AudioPlayer();

  List<_FloatingText> _floatingTexts = [];

  void _showFloatingText(String text, Offset position) {
    final id = UniqueKey();
    final floatingText = _FloatingText(id: id, text: text, position: position);
    setState(() => _floatingTexts.add(floatingText));

    // ให้มันค่อยๆ จางหายภายใน 1.2 วิ
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() => _floatingTexts.removeWhere((t) => t.id == id));
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _loadResources();
    fetchScore();
    fetchLeaderBoard();

    WidgetsBinding.instance.addObserver(this);
    playBackgroundMusic();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // แอปปัดไป home → pause แทน stop
      player.pause();
    } else if (state == AppLifecycleState.resumed) {
      // กลับมา foreground → เล่นต่อ
      player.resume();
    }
  }

  Future<void> fetchScore() async {
    String userId = await getUserId();
    final data = await getScore(userId);
    Map<String, dynamic> info = data['data']!;
    // print(data['rank']);
    if (!mounted) return;
    setState(() {
      _score = info['score'];
    });
  }

  Future<void> fetchLeaderBoard() async {
    final data = await getLeaderBoard();
    List<dynamic> info = data['data'];
    if (!mounted) return;
    setState(() {
      _leaderboardData = info;
    });
  }

  Future<void> handleScore(int newScore) async {
    String userId = await getUserId();
    await addScore(userId, newScore);
  }

  Future<void> _loadResources() async {
    // 1. สร้าง Audio Pool เตรียมไว้
    _chopPool = await FlameAudio.createPool(
      "choptree.mp3",
      minPlayers: 5,
      maxPlayers: 8,
    );

    _criticalPool = await FlameAudio.createPool(
      "criticalSound.WAV",
      minPlayers: 1,
      maxPlayers: 3,
    );

    // 2. โหลดไฟล์ Rive และตั้งค่า OneShotAnimation
    try {
      final data = await rootBundle.load(
        'assets/animations/rives/minigame_cutting.riv',
      );
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;

      final animation = OneShotAnimation(
        "play",
        autoplay: false,
        onStop: () {
          // เมื่อแอนิเมชันเล่นจบ ให้ปลด Cooldown
          if (mounted) {
            setState(() {
              _isCooldown = false;
            });
          }
        },
      );

      artboard.addController(animation);

      // เมื่อโหลดทุกอย่างเสร็จแล้ว ให้อัปเดต UI
      if (mounted) {
        setState(() {
          _artboard = artboard;
          _animation = animation;
          _isLoading = false;
        });
      }
    } catch (e) {
      // จัดการข้อผิดพลาดในการโหลดไฟล์ Rive
      print('Error loading Rive file: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> playBackgroundMusic() async {
    await player.setReleaseMode(ReleaseMode.loop); // เล่นวน
    await player.play(AssetSource('audio/quote_bg.mp3')); // ไฟล์ใน assets
    await player.setVolume(0);
  }

  void toggleMute() {
    setState(() {
      if (isMuted) {
        player.setVolume(1); // เปิดเสียง
      } else {
        player.setVolume(0); // mute
      }
      isMuted = !isMuted;
    });
  }

  @override
  void dispose() {
    _chopPool.dispose();
    _criticalPool.dispose();
    _pageController.dispose();
    player.dispose();
    super.dispose();
  }

  void _onTapScreen() {
    // ไม่ทำงานถ้ายังโหลดไม่เสร็จ หรือยังอยู่ใน Cooldown
    if (_isLoading || _isCooldown) return;
    final random = Random();
    double chance = random.nextDouble();
    int point = 1;

    if (chance < 0.05) {
      point = 5;
      print('ติดคริว่ะ');
      _criticalPool.start(); // 🔥 เล่นเสียงคริ
    } else if (chance < 0.10) {
      point = 3;
      print('ติดคริว่ะ');
      _criticalPool.start(); // 🔥 เล่นเสียงคริ
    } else {
      _chopPool.start(); // เสียงตัดไม้ปกติ
    }

    setState(() {
      _isCooldown = true; // เริ่ม Cooldown
      _score += point;
    });

    // เล่นแอนิเมชัน
    _animation?.isActive = true;

    String text = "+${point}";

    // ✅ กลางซ้ายของจอ
    final screenHeight = MediaQuery.of(context).size.height;

    _showFloatingText(
      text,
      Offset(80, screenHeight / 2 - 200), // ซ้าย 50px, กลางจอในแนวตั้ง
    );

    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(Duration(milliseconds: 1500), () async {
      await handleScore(_score);
    });
  }

  @override
  Widget build(BuildContext context) {
    final NavInfo = Provider.of<Navprovider>(context);
    return Scaffold(
      backgroundColor: Color(0xFFFFF7EB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            context.go('/');
            NavInfo.resetHome();
          },
        ),
        title: Text(
          currentPage == 0 ? 'มินิเกม' : 'จัดอันดับ',
          style: GoogleFonts.kanit(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: Color(0xFF78B465),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isMuted ? Icons.music_off : Icons.music_note,
              color: Color(0xFF78B465),
            ),
            onPressed: () {
              toggleMute();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 9,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) async {
                  setState(() {
                    currentPage = index; // อัปเดตหน้าปัจจุบัน
                  });

                  if (currentPage == 1) {
                    await fetchLeaderBoard();
                  } else if (currentPage == 0) {
                    await fetchScore();
                  }
                },
                // ป้องกันการสไลด์ด้วยนิ้ว
                // physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildGamePage(), // หน้า 1: Game
                  _buildLeaderboardPage(), // หน้า 0: Leaderboard
                ],
              ),
            ),
            Expanded(
              child: AnimatedSmoothIndicator(
                activeIndex: currentPage,
                count: 2,
                effect: WormEffect(
                  dotHeight: 12,
                  dotWidth: 12,
                  activeDotColor: const Color(0xFF78B465),
                  dotColor: Colors.grey.shade300,
                ),
                onDotClicked: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardPage() {
    return ZoomIn(
      duration: Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: ListView.builder(
                shrinkWrap: true, // ทำให้ ListView ขนาดเท่ากับเนื้อหา
                padding: EdgeInsets.zero,
                itemCount: _leaderboardData.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1. Rank
                          Expanded(
                            flex: 3,
                            child: Text(
                              'อันดับ',
                              style: GoogleFonts.kanit(
                                color: Color(0xFF464646),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),

                          // 2. User (รูป + ชื่อ)
                          Expanded(
                            flex: 3,
                            child: Text(
                              'ชื่อผู้เล่น',
                              style: GoogleFonts.kanit(
                                color: Color(0xFF464646),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          // 3. Score
                          Expanded(
                            flex: 3,
                            child: Text(
                              "คะแนน",
                              style: GoogleFonts.kanit(
                                color: Color(0xFF464646),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final player = _leaderboardData[index - 1];

                  return ZoomIn(
                    duration: Duration(milliseconds: 500),
                    child: CardScore(
                      rank: '${index}',
                      userId: player['userId'],
                      score: player['score'],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamePage() {
    return ZoomIn(
      duration: Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: _onTapScreen,
        child: Column(
          children: [
            // --- ส่วนแสดงคะแนน ---
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, right: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    border: Border.all(width: 2, color: Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: SvgPicture.asset("assets/icons/wood.svg"),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_score',
                        style: GoogleFonts.kanit(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF464646),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- ส่วนแอนิเมชัน ---
            Expanded(
              child: Stack(
                children: [
                  // Rive Animation (อยู่ด้านล่าง)
                  ZoomIn(
                    duration: Duration(milliseconds: 500),
                    child:
                        _isLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF78B465),
                              ),
                            )
                            : Rive(artboard: _artboard!, fit: BoxFit.contain),
                  ),

                  // Floating Texts (อยู่ด้านบน)
                  ..._floatingTexts.map((t) {
                    return Positioned(
                      key: t.id,
                      left: t.position.dx,
                      top: t.position.dy,
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(t.id),
                        tween: Tween(begin: 1.0, end: 0.0),
                        duration: const Duration(milliseconds: 2500),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, -200 * (1 - value)),
                              child: Text(
                                t.text,
                                style: GoogleFonts.kanit(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      t.text == "+5"
                                          ? Colors.redAccent.withOpacity(value)
                                          : t.text == "+3"
                                          ? Colors.orangeAccent.withOpacity(
                                            value,
                                          )
                                          : Colors.black.withOpacity(value),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            Text(
              "แตะเพื่อตัดต้นไม้และเก็บคะแนน\nใครเก็บคะแนนได้สูงสุดมีรางวัลพิเศษ !!",
              style: GoogleFonts.kanit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF464646),
                height: 2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CardScore extends StatefulWidget {
  final String rank;
  final String userId;
  final int score;
  const CardScore({
    super.key,
    required this.rank,
    required this.userId,
    required this.score,
  });

  @override
  State<CardScore> createState() => _CardScoreState();
}

class _CardScoreState extends State<CardScore> {
  Map<String, dynamic> userInfo = {};

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final user = await getuserById(widget.userId);
    if (!mounted) return;
    setState(() {
      userInfo = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userImg =
        userInfo['photoURL'].toString().trim().isNotEmpty
            ? userInfo['photoURL']
            : "https://firebasestorage.googleapis.com/v0/b/healjaiapp-60ec3.firebasestorage.app/o/AssetsInApp%2Fprofile.png?alt=media&token=8cdff07d-64e1-4d02-b83d-af54648f52a0";

    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 10),
      child: Row(
        children: [
          // 1. Rank
          SizedBox(
            width: 70, // กำหนดความกว้างคงที่
            child: Text(
              '${widget.rank}.',
              style: GoogleFonts.kanit(
                color: Color(0xFF464646),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.start,
            ),
          ),

          // 2. User (รูป + ชื่อ)
          Expanded(
            child: Row(
              children: [
                userImg == null
                    ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                    : CircleAvatar(
                      radius: 25,
                      backgroundImage: CachedNetworkImageProvider(userImg),
                    ),
                SizedBox(width: 20), // ระยะห่างระหว่างรูปกับชื่อ
                Expanded(
                  child:
                      userInfo['username'] == null
                          ? Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 50,
                              height: 20,
                              decoration: BoxDecoration(color: Colors.grey),
                            ),
                          )
                          : Text(
                            '${userInfo['username']}',
                            style: GoogleFonts.kanit(
                              color: Color(0xFF464646),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                ),
              ],
            ),
          ),

          // 3. Score
          SizedBox(
            width: 60, // กำหนดความกว้างคงที่
            child: Text(
              "${widget.score}",
              style: GoogleFonts.kanit(
                color: Color(0xFF464646),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
