import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


import 'package:healjai_project/Widgets/Home/WelcomeSection.dart';
import 'package:healjai_project/Widgets/Home/DiarySection.dart';

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
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 10),
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
                  const SizedBox(height: 50),
                  DiarySection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}