import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class Bookdetail extends StatefulWidget {
  final Map<String, dynamic>? data;
  const Bookdetail({super.key, this.data});

  @override
  State<Bookdetail> createState() => _BookdetailState();
}

class _BookdetailState extends State<Bookdetail> {
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
              ClipRRect(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 270,
                      color: Colors.transparent,
                    ),
                    Image.network(
                      widget.data?['slideImg'] ?? '',
                      width: double.infinity,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          // โหลดเสร็จแล้ว → แสดงรูปจริง
                          return child;
                        }
                        // กำลังโหลด → แสดง shimmer
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: double.infinity,
                            height: 270,
                            color: Colors.grey[300],
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        // ถ้าโหลดรูปไม่ได้
                        return Container(
                          width: double.infinity,
                          height: 270,
                          color: Colors.grey[200],
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Padding(
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
                      itemCount: widget.data?['info']['importanceInfo'].length,
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
                      itemCount: widget.data?['info']['importanceInfo'].length,
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
                      itemCount: widget.data?['info']['techniques'].length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            '\t\t•  ${widget.data?['info']['techniques'][index]}',
                            style: GoogleFonts.kanit(
                              fontSize: 15,
                              color: Color(0xFF464646),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
