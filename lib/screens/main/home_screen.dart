import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


import '../../Widgets/WelcomeSection.dart';
import '../../Widgets/activities_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int activeIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();
  @override
  Widget build(BuildContext context) {
    return ZoomIn(
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.only(top: 25),
        child: SingleChildScrollView(
          child: FractionallySizedBox(
            widthFactor: 0.9,
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
                    onPageChanged: (index, reason) =>
                        setState(() => activeIndex = index),
                  ),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                
                // 👇 3. เรียกใช้ Class Widget ใหม่ที่เราสร้างขึ้น
                const ActivitiesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}