import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../service/authen.dart';
import '../providers/userProvider.dart';

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
    final userInfo = Provider.of<UserInfo>(context);

    return BounceInDown(
      duration: Duration(milliseconds: 800),
      child: Container(
        margin: EdgeInsets.only(top: 10, bottom: 20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HealJai',
                style: GoogleFonts.mali(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF78B465),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      spreadRadius: 0,
                      blurRadius: 7,
                      offset: Offset(0, 8), // เงาด้านล่าง
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white, // สีขอบ
                    width: 3,
                  ),
                ),
                child: GestureDetector(
                  onTap: () async {
                    if (userInfo.userId != null) {
                      await clearUserLocal(); // clear local
                      await userInfo.clearUserInfo(); // clear Provider
                      context.pop();
                    } else {
                      context.push('/login');
                    }
                  },
                  child: CircleAvatar(
                    backgroundImage:
                        userInfo.userPhoto != null
                            ? NetworkImage(userInfo.userPhoto!)
                            : AssetImage('assets/images/profile.png'),
                    radius: 26,
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
