import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/quote.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Quotedetail extends StatefulWidget {
  final Map<String, dynamic>? data;
  const Quotedetail({super.key, this.data});

  @override
  State<Quotedetail> createState() => _QuotedetailState();
}

class _QuotedetailState extends State<Quotedetail> with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int activeIndex = 0;
  final player = AudioPlayer();
  late List<Map<String, dynamic>> quoteLst = [];
  bool isMuted = true;
  bool is_Loading = false;

  @override
  void initState() {
    super.initState();
    widget.data?['type'] == 'bookmark' ? fetchQuoteBookmark() : fetchQuote(widget.data?['type']);
    // เข้าถึง widget.data ได้ใน initState
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

  Future<void> fetchQuoteBookmark() async {
    if (is_Loading) return;
    setState(() {
      is_Loading = true;
    });
    String userId = await getUserId();
    final data = await getMyquoteBookmark(userId);
    setState(() {
      quoteLst = data;
      is_Loading = false;
    });
  }

  Future<void> fetchQuote(String type) async {
    if (is_Loading) return;
    setState(() {
      is_Loading = true;
    });
    final data = await getQuote(type);
    setState(() {
      quoteLst = data;
      is_Loading = false;
    });
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
    player.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            context.pop('/');
          },
        ),
        title: Text(
          'Quote',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            children: [
              Expanded(
                child:
                    is_Loading
                        ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: SpinKitCircle(
                            color: Color(0xFF78B465),
                            size: 100.0,
                          ),
                        )
                        : quoteLst.isNotEmpty
                        ? PageView.builder(
                          controller: _pageController,
                          itemCount: quoteLst.length,
                          itemBuilder: (context, index) {
                            final Map<String, dynamic> quoteObg =
                                quoteLst[index];
                            return QuoteCard(
                              key: PageStorageKey('quote_$index'),
                              quoteInfo: quoteObg['info'] ?? '',
                              quoteImg: quoteObg['img'] ?? '',
                              quoteId: quoteObg['_id'] ?? '',
                            );
                          },
                          scrollDirection: Axis.horizontal, // ปัดซ้าย-ขวา
                          onPageChanged: (index) {
                            setState(() {
                              activeIndex = index; // อัพเดต active dot
                            });
                          },
                        )
                        : Center(
                          child: Text(
                            "ยังไม่มี Quote ที่บันทึกไว้",
                            style: GoogleFonts.kanit(
                              fontSize: 20,
                              color: Color(0xFF464646),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
              ),
              quoteLst.isNotEmpty
                  ? Center(
                    child: AnimatedSmoothIndicator(
                      activeIndex: activeIndex,
                      count: quoteLst.length,
                      effect: ScrollingDotsEffect(
                        activeDotColor: Color(0xFF78B465),
                        dotColor: Colors.grey.shade300,
                        dotHeight: 10,
                        dotWidth: 10,
                        maxVisibleDots: 9, // แสดงแค่ 10 dot รอบ active
                      ),
                      onDotClicked: (index) {
                        _pageController.animateToPage(
                          index,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  )
                  : SizedBox.shrink(),
                  SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class QuoteCard extends StatefulWidget {
  final String quoteInfo;
  final String quoteImg;
  final String quoteId;

  const QuoteCard({
    super.key,
    required this.quoteInfo,
    required this.quoteImg,
    required this.quoteId,
  });

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  bool isFavorite = false;
  bool isBookmark = false;

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลทั้งหมด
    loadAllData();
  }

  Future<void> loadAllData() async {
    await Future.wait([fetchStateQuoteLike(), fetchStateQuoteBookmark()]);
  }

  //ฟังก์ชั่นกดไลก์ Quote
  Future<void> likeHandle() async {
    if (!mounted) return;
    setState(() {
      isFavorite = !isFavorite;
    });

    String userId = await getUserId();
    await addQuoteLike(userId, widget.quoteId);
  }

  //ฟังก์ชั่นกดบันทึก Quote
  Future<void> boomarkHandle() async {
    if (!mounted) return;
    setState(() {
      isBookmark = !isBookmark;
    });

    String userId = await getUserId();
    await addQuoteBookmark(userId, widget.quoteId);
  }

  // เรียกสถานะ Like ของ Quote
  Future<void> fetchStateQuoteLike() async {
    String userId = await getUserId();
    final data = await getStateQuoteLike(userId, widget.quoteId);
    final state = data['success'];
    if (!mounted) return;
    setState(() {
      isFavorite = state;
    });
  }

  // เรียกสถานะ Bookmark ของ Quote
  Future<void> fetchStateQuoteBookmark() async {
    String userId = await getUserId();
    final data = await getStateQuoteBookmark(userId, widget.quoteId);
    final state = data['success'];
    if (!mounted) return;
    setState(() {
      isBookmark = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ZoomIn(
      duration: Duration(milliseconds: 500),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // รูปสูง 50% ของ Container
                    SizedBox(
                      height: constraints.maxHeight * 0.4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: widget.quoteImg,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder:
                              (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: double.infinity,
                                  height: 200, // ปรับความสูงตามต้องการ
                                  color: Colors.grey[300],
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                    ),
                    // เนื้อหา
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 15,
                        left: 15,
                        right: 15,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            widget.quoteInfo,
                            style: GoogleFonts.kanit(
                              fontSize: 20,
                              color: Color(0xFF464646),
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: Color.fromARGB(255, 201, 201, 201),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: Color(0xFFFFC9C9),
                                child: IconButton(
                                  onPressed: () async {
                                    await likeHandle();
                                  },
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_outline,
                                    color: Color(0xFFFD7D7E),
                                  ),
                                  highlightColor: Colors.transparent,
                                ),
                              ),
                              SizedBox(width: 20),
                              CircleAvatar(
                                backgroundColor: Color(0xFFD5D0FF),
                                child: IconButton(
                                  onPressed: () {
                                    boomarkHandle();
                                  },
                                  icon: Icon(
                                    isBookmark
                                        ? Icons.bookmark
                                        : Icons.bookmark_outline,
                                    color: Color(0xFF7F71FF),
                                  ),
                                  highlightColor: Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
