import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

List<Widget> welcomeSlideList = [
  WelcomeSection(),
  QuoteTemplate(quoteAsset: "assets/images/quote_1.png"),
  QuoteTemplate(quoteAsset: "assets/images/quote_2.png"),
  QuoteTemplate(quoteAsset: "assets/images/quote_3.png"),
  QuoteTemplate(quoteAsset: "assets/images/quote_4.png"),
];


class WelcomeSection extends StatefulWidget {
  const WelcomeSection({super.key});

  @override
  State<WelcomeSection> createState() => _WelcomeSectionState();
}

class _WelcomeSectionState extends State<WelcomeSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.transparent,

        ),
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

  const QuoteTemplate(
    {super.key,  required this.quoteAsset});

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