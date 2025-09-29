import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/providers/DiaryProvider.dart';
import 'package:healjai_project/providers/TrackerProvider.dart';
import 'package:healjai_project/providers/navProvider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/providers/userProvider.dart';

class HeaderSection extends StatefulWidget {
  const HeaderSection({super.key});

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserProvider>(context);
    final TreeInfo = Provider.of<TrackerProvider>(context);
    final DiaryInfo = Provider.of<DiaryProvider>(context);
    final NavInfo = Provider.of<Navprovider>(context);

    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HealJai',
                style: GoogleFonts.mali(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF78B465),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (userInfo.userId != null) {
                    await logout();
                    await userInfo.clearUserInfo(); // clear Provider
                    await TreeInfo.clearTree();
                    await DiaryInfo.clearTask();
                    context.go('/');
                    NavInfo.resetHome();
                  } else {
                    context.push('/login');
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        spreadRadius: 0,
                        blurRadius: 3,
                        offset: Offset(0, 1), // เงาด้านล่าง
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white, // สีขอบ
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child:
                        userInfo.userPhoto != null
                            ? Image.network(
                              userInfo.userPhoto!,
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 55,
                                    height: 55,
                                    color: Colors.white,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/profile.png',
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                            : Image.asset(
                              'assets/images/profile.png',
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                            ),
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
