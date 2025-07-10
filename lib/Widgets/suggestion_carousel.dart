import 'package:flutter/material.dart';

class SuggestionCarousel extends StatefulWidget {
  const SuggestionCarousel({super.key});

  @override
  State<SuggestionCarousel> createState() => _SuggestionCarouselState();
}

class _SuggestionCarouselState extends State<SuggestionCarousel> {
  final PageController _controller = PageController();
  int _current = 0;

  final suggestions = [
    'ร้องเพลงหรือเต้นตามเพลงช่วยผ่อนคลายดีนะ 🎵',
    'วันนี้เต้นตามแอป 15 นาทีสดชื่นเลย ✨',
    'ตั้งเวลาเปิดเพลงสบายๆ แล้วปล่อยใจช้าๆ 🌿',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'เหนื่อยมากมั้ยวันนี้ ?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (index) => setState(() => _current = index),
            itemCount: suggestions.length,
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      suggestions[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(suggestions.length, (i) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _current ? Color.fromARGB(255, 79, 138, 65) : Colors.grey.shade300,
              ),
            );
          }),
        ),
      ],
    );
  }
}
