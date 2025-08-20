import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

List<Widget> welcomeSlideList = [
  WelcomeCard(),
  QuoteTemplate(quoteAsset: "assets/images/quote_1.png"),
  QuoteTemplate(quoteAsset: "assets/images/quote_2.png"),
  QuoteTemplate(quoteAsset: "assets/images/quote_3.png"),
  QuoteTemplate(quoteAsset: "assets/images/quote_4.png"),
];

class Welcomesection extends StatefulWidget {
  const Welcomesection({super.key});

  @override
  State<Welcomesection> createState() => _WelcomesectionState();
}

class _WelcomesectionState extends State<Welcomesection> {
  int activeIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: welcomeSlideList.length,
            itemBuilder: (context, index, realIndex) {
              return welcomeSlideList[index];
            },
            options: CarouselOptions(
              height: 300,
              autoPlay: true,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              onPageChanged:
                  (index, reason) => setState(() => activeIndex = index),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSmoothIndicator(
            activeIndex: activeIndex,
            count: welcomeSlideList.length,
            effect: WormEffect(
              dotHeight: 12,
              dotWidth: 12,
              activeDotColor: const Color(0xFF78B465),
              dotColor: Colors.grey.shade300,
            ),
            onDotClicked: (index) {
              _carouselController.animateToPage(index);
            },
          ),
        ],
      ),
    );
  }
}

class WelcomeCard extends StatefulWidget {
  const WelcomeCard({super.key});

  @override
  State<WelcomeCard> createState() => _WelcomeCardState();
}

class _WelcomeCardState extends State<WelcomeCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(color: Colors.transparent),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "ยินดีต้อนรับเข้าสู่ HealJai นะ",
            style: GoogleFonts.mali(
              color: Color(0xFF78B465),
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          SpinPerfect(
            infinite: true,
            duration: Duration(seconds: 60),
            child: Container(
              width: 230,
              height: 230,
              child: Image.asset('assets/images/welcome.png'),
            ),
          ),
        ],
      ),
    );
  }
}

class QuoteTemplate extends StatefulWidget {
  final String quoteAsset;

  const QuoteTemplate({super.key, required this.quoteAsset});

  @override
  State<QuoteTemplate> createState() => _QuoteTemplateState();
}

class _QuoteTemplateState extends State<QuoteTemplate> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      child: Image.asset(widget.quoteAsset),
    );
  }
}
