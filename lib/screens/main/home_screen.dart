import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../Widgets/WelcomeSection.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  int activeIndex = 0;
  CarouselSliderController CarouselController = CarouselSliderController();

  Widget build(BuildContext context) {

    return ZoomIn(
      duration: Duration(milliseconds: 500),
      child: Container(
        margin: EdgeInsets.only(top: 25),
        child: FractionallySizedBox(
          widthFactor: 0.9,
          child: Column(
            children: [
              CarouselSlider.builder(
                carouselController: CarouselController,
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
              SizedBox(height: 20),
              AnimatedSmoothIndicator(
                activeIndex: activeIndex,
                count: welcomeSlideList.length,
                effect: WormEffect(
                  dotHeight: 12,
                  dotWidth: 12,
                  activeDotColor: Color(0xFF78B465),
                  dotColor: Colors.grey.shade300,
                ),
                onDotClicked: (index) {
                  CarouselController.animateToPage(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


