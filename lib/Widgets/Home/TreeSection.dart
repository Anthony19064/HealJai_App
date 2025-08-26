import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/providers/TreeProvider.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

class TreeSection extends StatefulWidget {
  const TreeSection({super.key});

  @override
  State<TreeSection> createState() => _TreeSectionState();
}

class _TreeSectionState extends State<TreeSection> {
  @override
  Widget build(BuildContext context) {
    final TreeInfo = Provider.of<TreeProvider>(context);

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "ทำภารกิจเพื่อปลูกต้นของเธอ",
            style: GoogleFonts.mali(
              color: Color(0xFF78B465),
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),

          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.10,
              bottom: MediaQuery.of(context).size.height * 0.10,
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.60,
              height: 210,
              child: RiveAnimation.asset(
                'assets/animations/rives/tree.riv',
                animations: ['Seedling_lv1'],
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "สุดยอดเลยตอนนี้",
                textAlign: TextAlign.center,
                style: GoogleFonts.mali(
                  color: Color(0xFF464646),
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "อายุต้นไม้ของเธอ",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.mali(
                      color: Color(0xFF464646),
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: Text(
                      "${TreeInfo.TreeAge}",
                      style: GoogleFonts.mali(
                        color: Color(0xFF78B465),
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    "วันแล้วนะ",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.mali(
                      color: Color(0xFF464646),
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.020),
          ElevatedButton(
            onPressed: () {
              context.push('/diaryHistory');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF78B465),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 35,
                    height: 35,
                    child: SvgPicture.asset(
                      "assets/icons/history.svg",
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "ดูบันทึกประจำวันของฉัน",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.mali(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
