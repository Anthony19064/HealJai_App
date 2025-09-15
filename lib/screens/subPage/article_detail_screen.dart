// screens/article_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart'; // <-- 1. Import audioplayers

// ... (const Map articleCategories ไม่เปลี่ยนแปลง) ...
const Map<String, List<String>> articleCategories = {
  'ความสุข': [
    'ความสุข', 'ความสุข 2', 'ความสุข 3', 'ความสุข 4',
  ],
  'ความรัก': [
    'ความรัก', 'ความรัก 2', 'ความรัก 3', 'ความรัก 4',
  ],
  'กำลังใจ': [
    'กำลังใจ', 'กำลังใจ 2', 'กำลังใจ 3', 'กำลังใจ 4',
  ],
  'แบ่งปัน': [
    'แบ่งปัน', 'แบ่งปัน 2', 'แบ่งปัน 3', 'แบ่งปัน 4',
  ],
};

// --- เปลี่ยนเป็น StatefulWidget เพื่อจัดการ state ของเพลง ---
class ArticleDetailScreen extends StatefulWidget {
  final String title;
  const ArticleDetailScreen({super.key, required this.title});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> with WidgetsBindingObserver { // <-- 2. เพิ่ม "with WidgetsBindingObserver" เพื่อเช็คสถานะแอป
  
  final AudioPlayer _audioPlayer = AudioPlayer(); // <-- 3. สร้าง instance ของ AudioPlayer
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // <-- เพิ่ม observer เพื่อเช็คสถานะแอป
    _playMusic();
  }

  void _playMusic() async {
    try {
      // 4. ระบุที่อยู่ของไฟล์เพลงใน assets
      await _audioPlayer.play(AssetSource('audio/background_music.mp3')); 
      _audioPlayer.setReleaseMode(ReleaseMode.loop); // ทำให้เพลงเล่นวน
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      // จัดการกรณีหาไฟล์เพลงไม่เจอหรือไม่สามารถเล่นได้
      debugPrint("Error playing music: $e");
    }
  }

  // ฟังก์ชันสำหรับสลับการเล่น/หยุดเพลง
  void _toggleMusic() {
    if (_isPlaying) {
      _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      _audioPlayer.resume();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  // จัดการเมื่อแอปถูกย่อ/ปิด
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_isPlaying) {
        _audioPlayer.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isPlaying) {
        _audioPlayer.resume();
      }
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // <-- ลบ observer
    _audioPlayer.stop(); // <-- 5. หยุดและเคลียร์ memory เมื่อออกจากหน้านี้
    _audioPlayer.dispose();
    super.dispose();
  }

  // ... (ฟังก์ชัน _getArticleData ไม่เปลี่ยนแปลง) ...
  Map<String, String> _getArticleData(String title) {
    // ... โค้ดเดิม
    switch (title) {
      case 'ความสุข':
        return {
          'imagePath': 'assets/images/wagu1.jpg',
          'header': 'บางครั้งความสุขก็เกิดขึ้นจากเรื่องเล็กๆ',
          'body': 'เราแค่มองข้ามเรื่องเล็กๆน้อยๆไปเท่านั้นเอง ความสุขมันอยู่รอบตัวเรานั่นแหละ เช่น วันนี้อากาศดีจัง ข้าวร้านนี้อร่อยจัง เห็นไหมทุกอย่างก็คือความสุขเล็กๆน้อยๆนั่นแหละ :)'
        };
      case 'ความสุข 2':
        return {
          'imagePath': 'assets/images/happy2.jpg',
          'header': 'ขอบคุณตัวเองบ้างนะ',
          'body': 'อย่าลืมขอบคุณตัวเองที่ผ่านเรื่องราวต่างๆ มาได้จนถึงทุกวันนี้ เธอน่ะเก่งที่สุดแล้วนะรู้ไหม'
        };
      case 'ความสุข 3':
        return {
          'imagePath': 'assets/images/happy3.jpg',
          'header': 'ลองทำอะไรใหม่ๆ ดูบ้าง',
          'body': 'การออกจาก comfort zone ไปลองทำอะไรที่ไม่เคยทำ อาจทำให้เราค้นพบความสุขในรูปแบบใหม่ๆ ที่ไม่เคยเจอมาก่อนก็ได้นะ'
        };
      case 'ความสุข 4':
        return {
          'imagePath': 'assets/images/happy4.jpg',
          'header': 'ความสุขคือการอยู่กับปัจจุบัน',
          'body': 'ไม่ต้องกังวลกับอนาคต ไม่ต้องยึดติดกับอดีต ลองใช้ชีวิตอยู่กับปัจจุบันขณะดูสิ แล้วจะรู้ว่าความสุขมันอยู่ตรงนี้เอง'
        };
        
      case 'ความรัก':
        return {
          'imagePath': 'assets/images/wagu2.jpg',
          'header': 'นิยามของความรักสำหรับคุณคืออะไร?',
          'body': 'สำหรับบางคน ความรักคือการให้ สำหรับบางคนคือการดูแลเอาใจใส่ ไม่ว่านิยามของคุณจะเป็นแบบไหน ขอแค่มีความสุขกับมันก็พอแล้ว'
        };
      case 'ความรัก 2':
        return {
          'imagePath': 'assets/images/love2.jpg',
          'header': 'รักตัวเองให้เป็น',
          'body': 'ก่อนที่จะมอบความรักให้ใคร อย่าลืมที่จะรักตัวเองก่อนนะ การรักตัวเองจะทำให้เรามีพลังที่จะส่งต่อความรักดีๆ ให้คนอื่นได้'
        };
      case 'ความรัก 3':
        return {
          'imagePath': 'assets/images/love3.jpg',
          'header': 'ความรักไม่ใช่การครอบครอง',
          'body': 'ความรักที่แท้จริงคือการเห็นคนที่เรารักมีความสุข แม้ว่าความสุขนั้นอาจจะไม่มีเราอยู่ข้างๆ ก็ตาม'
        };
      case 'ความรัก 4':
        return {
          'imagePath': 'assets/images/love4.jpg',
          'header': 'ภาษารัก 5 รูปแบบ',
          'body': 'การแสดงความรักมีหลายวิธี ลองศึกษาภาษารักทั้ง 5 รูปแบบดูสิ จะได้เข้าใจและแสดงความรักกับคนข้างๆ ได้ดียิ่งขึ้น'
        };

      case 'กำลังใจ':
         return {
          'imagePath': 'assets/images/wagu3.jpg',
          'header': 'เหนื่อยไหม? แวะมาเติมกำลังใจตรงนี้ก่อน',
          'body': 'ไม่เป็นไรนะถ้าจะเหนื่อยบ้าง ท้อบ้าง ขอแค่อย่าเพิ่งยอมแพ้ ทุกปัญชามีทางออกเสมอ กอดๆนะ'
        };
      case 'กำลังใจ 2':
        return {
          'imagePath': 'assets/images/encourage2.jpg',
          'header': 'ทุกก้าวมีความหมาย',
          'body': 'แม้จะเป็นก้าวเล็กๆ แต่มันก็คือก้าวที่พาเราเข้าใกล้เป้าหมายเสมอ อย่าเพิ่งหมดหวังกับเส้นทางที่เลือกเดินนะ'
        };
      case 'กำลังใจ 3':
        return {
          'imagePath': 'assets/images/encourage3.jpg',
          'header': 'พายุผ่านไป ฟ้าย่อมสดใสเสมอ',
          'body': 'เรื่องร้ายๆ ที่เข้ามาในชีวิตก็เหมือนพายุ เดี๋ยวมันก็ผ่านไป และเมื่อมันผ่านไปแล้ว ท้องฟ้าที่สวยงามจะรอเราอยู่เสมอ'
        };
       case 'กำลังใจ 4':
        return {
          'imagePath': 'assets/images/encourage4.jpg',
          'header': 'เธอไม่ได้อยู่คนเดียวนะ',
          'body': 'เมื่อไหร่ที่รู้สึกโดดเดี่ยว ลองมองไปรอบๆ ตัวสิ ยังมีคนที่พร้อมจะรับฟังและอยู่ข้างๆ เธอเสมอนะ'
        };

      case 'แบ่งปัน':
        return {
          'imagePath': 'assets/images/wagu4.jpg',
          'header': 'การแบ่งปันคือความสุขที่ยิ่งใหญ่',
          'body': 'เคยไหมที่รู้สึกอิ่มใจเมื่อได้ให้? การแบ่งปันไม่จำเป็นต้องเป็นสิ่งของเสมอไป แค่รอยยิ้มหรือคำพูดดีๆ ก็เป็นการแบ่งปันความสุขได้แล้ว'
        };
       case 'แบ่งปัน 2':
        return {
          'imagePath': 'assets/images/share2.jpg',
          'header': 'ยิ่งให้ ยิ่งได้',
          'body': 'ความสุขจากการเป็นผู้ให้ คือความสุขที่เราไม่ต้องไปร้องขอจากใคร มันเกิดขึ้นเองจากข้างในใจของเรา'
        };
       case 'แบ่งปัน 3':
        return {
          'imagePath': 'assets/images/share3.jpg',
          'header': 'แบ่งปันเวลา',
          'body': 'สิ่งที่มีค่าที่สุดที่เราจะมอบให้ใครสักคนได้ ก็คือ "เวลา" ของเรานั่นเอง ลองแบ่งปันเวลาให้คนที่คุณรักดูสิ'
        };
       case 'แบ่งปัน 4':
        return {
          'imagePath': 'assets/images/share4.jpg',
          'header': 'สังคมน่าอยู่ด้วยการแบ่งปัน',
          'body': 'แค่สิ่งเล็กๆ น้อยๆ ที่เราแบ่งปันให้คนรอบข้าง อาจจะเป็นจุดเริ่มต้นที่ทำให้สังคมของเราน่าอยู่ขึ้นก็ได้นะ'
        };

      default:
        return {
          'imagePath': 'assets/images/wagu1.jpg',
          'header': 'ไม่พบข้อมูลบทความ',
          'body': 'ขออภัย ไม่พบเนื้อหาสำหรับบทความ "${widget.title}"'
        };
    }
  }


  @override
  Widget build(BuildContext context) {
    final articleData = _getArticleData(widget.title);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB),

      // ============== ▼▼▼ 6. เพิ่มปุ่มเปิด/ปิดเพลง ▼▼▼ ==============
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMusic,
        backgroundColor: Colors.white,
        child: Icon(
          _isPlaying ? Icons.volume_up_rounded : Icons.volume_off_rounded,
          color: const Color(0xFF78B465),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF5A5A5A),
                  size: 28,
                ),
                onPressed: () => context.pop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          articleData['imagePath']!,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.image_not_supported_outlined,
                                    color: Colors.grey, size: 50),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            articleData['header']!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.mali(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF5A5A5A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            articleData['body']!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.mali(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        List<String>? categoryArticles;
                        articleCategories.forEach((key, value) {
                          if (value.contains(widget.title)) {
                            categoryArticles = value;
                          }
                        });

                        if (categoryArticles != null) {
                          final currentIndex = categoryArticles!.indexOf(widget.title);
                          final nextIndex = (currentIndex + 1) % categoryArticles!.length;
                          final nextTitle = categoryArticles![nextIndex];
                          context.pushReplacement('/book/$nextTitle');
                        } else {
                          context.pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8CC63F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        elevation: 5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_forward_ios,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'ถัดไป',
                            style: GoogleFonts.mali(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}