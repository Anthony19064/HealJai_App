import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/data_Lists/article_Lst.dart';
import 'package:healjai_project/providers/navProvider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int activeIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  List<Widget> get bookSlideList => [
    SlideContainer(ArticleLst[0]),
    SlideContainer(ArticleLst[1]),
    SlideContainer(ArticleLst[2]),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NavInfo = Provider.of<Navprovider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB),
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
          'บทความ',
          style: GoogleFonts.kanit(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: Color(0xFF78B465),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
            bottom: 15,
            left: 15,
            right: 15,
          ),
          child: NestedScrollView(
            headerSliverBuilder:
                (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    floating: true,
                    snap: false,
                    pinned: false,
                    automaticallyImplyLeading: false,
                    toolbarHeight: 300,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "บทความแนะนำ",
                          textAlign: TextAlign.start,
                          style: GoogleFonts.kanit(
                            color: Color(0xFF464646),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 20),
                        ZoomIn(
                          duration: Duration(milliseconds: 500),
                          child: CarouselSlider.builder(
                            carouselController: _carouselController,
                            itemCount: bookSlideList.length,
                            itemBuilder: (context, index, realIndex) {
                              return bookSlideList[index];
                            },
                            options: CarouselOptions(
                              height: 200,
                              autoPlay: true,
                              viewportFraction: 1.0,
                              enlargeCenterPage: false,
                              onPageChanged:
                                  (index, reason) =>
                                      setState(() => activeIndex = index),
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        Center(
                          child: AnimatedSmoothIndicator(
                            activeIndex: activeIndex,
                            count: bookSlideList.length,
                            effect: WormEffect(
                              dotHeight: 10,
                              dotWidth: 10,
                              activeDotColor: const Color(0xFF78B465),
                              dotColor: Colors.grey.shade300,
                            ),
                            onDotClicked: (index) {
                              _carouselController.animateToPage(index);
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                    centerTitle: false,
                    titleSpacing: 0,
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelStyle: GoogleFonts.kanit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        labelColor: Color(0xFF78B465),
                        unselectedLabelColor: Color(0xFF464646),
                        indicatorColor: Color(0xFF78B465),
                        tabs: const [
                          Tab(text: "บทความ"),
                          Tab(text: "Quote"),
                          Tab(text: "ที่บันทึกไว้"),
                        ],
                      ),
                    ),
                  ),
                ],
            body: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                // widget list ข้างใน
                Article(),
                quote(),
                bookmark(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget SlideContainer(Map<String, dynamic> bookObj) {
    return GestureDetector(
      onTap: () {
        context.push('/bookInfo', extra: bookObj);
      },
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                color: Colors.grey[300],
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Image.network(
              bookObj['slideImg']!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget cardInfo(Map<String, dynamic> bookObj) {
    return ZoomIn(
      duration: Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () {
          context.push('/bookInfo', extra: bookObj);
        },
        child: Container(
          width: double.infinity,
          height: 120,
          margin: EdgeInsets.only(top: 15),
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      bookObj['title']!,
                      style: GoogleFonts.kanit(
                        fontSize: 17,
                        color: Color(0xFF464646),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      bookObj['description']!,
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        color: Color(0xFF464646),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Stack(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        bookObj['ExImg']!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget Article() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: ArticleLst.length,
            itemBuilder: (context, index) {
              return cardInfo(ArticleLst[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget quote() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: quoteLst.length,
            itemBuilder: (context, index) {
              return cardInfo(quoteLst[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget bookmark() {
    return bookmarkLst.isNotEmpty
        ? SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: bookmarkLst.length,
                itemBuilder: (context, index) {
                  return cardInfo(bookmarkLst[index]);
                },
              ),
            ],
          ),
        )
        : Center(
          child: Text(
            "ไม่มีบทความหรือ Quote ที่บันทึกไว้",
            style: GoogleFonts.kanit(
              color: Color(0xFF464646),
              fontSize: 23,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
  }
}

// สร้าง delegate สำหรับ SliverPersistentHeader
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFFFFF7EB), child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
