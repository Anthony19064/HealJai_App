import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class Articledetail extends StatefulWidget {
  final Map<String, dynamic>? data;
  const Articledetail({super.key, this.data});

  @override
  State<Articledetail> createState() => _ArticledetailState();
}

class _ArticledetailState extends State<Articledetail> {
  @override
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              ZoomIn(
                duration: Duration(milliseconds: 500),
                child: ClipRRect(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 270,
                        color: Colors.transparent,
                      ),
                      CachedNetworkImage(
                        imageUrl: widget.data?['slideImg'] ?? '',
                        width: double.infinity,
                        fit: BoxFit.contain,
                        placeholder:
                            (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: double.infinity,
                                height: 270,
                                color: Colors.grey[300],
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              width: double.infinity,
                              height: 270,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              FadeIn(
                duration: Duration(milliseconds: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //หัวข้อบทความ
                      Center(
                        child: Text(
                          widget.data?['title'],
                          style: GoogleFonts.kanit(
                            fontSize: 22,
                            color: Color(0xFF464646),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // เกริ่นนำ
                      Text(
                        '\t\t\t\t\t\t${widget.data?['info']['intro']}',
                        style: GoogleFonts.kanit(
                          fontSize: 15,
                          color: Color(0xFF464646),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 30),
                      //หัวข้อสำคัญ
                      Text(
                        widget.data?['info']['importanceTitle'],
                        style: GoogleFonts.kanit(
                          fontSize: 20,
                          color: Color(0xFF464646),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10),
                      //เนื้อหาหัวข้อสำคัญ
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            widget.data?['info']['importanceInfo'].length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              '\t\t•  ${widget.data?['info']['importanceInfo'][index]}',
                              style: GoogleFonts.kanit(
                                fontSize: 15,
                                color: Color(0xFF464646),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 30),
                      //หัวข้อประโยชน์
                      Text(
                        widget.data?['info']['benefitsTitle'],
                        style: GoogleFonts.kanit(
                          fontSize: 20,
                          color: Color(0xFF464646),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10),
                      //เนื้อหาของประโยชน์
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.data?['info']['benefitsInfo'].length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              '\t\t•  ${widget.data?['info']['benefitsInfo'][index]}',
                              style: GoogleFonts.kanit(
                                fontSize: 15,
                                color: Color(0xFF464646),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 30),
                      //หัวข้อเทคนิค
                      Text(
                        widget.data?['info']['techniquesTitle'],
                        style: GoogleFonts.kanit(
                          fontSize: 20,
                          color: Color(0xFF464646),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10),
                      //เนื้อหาของเทคนิค
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            widget.data?['info']['techniquesInfo'].length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              '\t\t•  ${widget.data?['info']['techniquesInfo'][index]}',
                              style: GoogleFonts.kanit(
                                fontSize: 15,
                                color: Color(0xFF464646),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 30),
                      Text(
                        "สรุปเรื่อง${widget.data?['title']}",
                        style: GoogleFonts.kanit(
                          fontSize: 20,
                          color: Color(0xFF464646),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '\t\t\t\t\t\t${widget.data?['info']['summary']}',
                        style: GoogleFonts.kanit(
                          fontSize: 15,
                          color: Color(0xFF464646),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
