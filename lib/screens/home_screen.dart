import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../providers/userProvider.dart';

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

  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserInfo>(context);

    return Column(
      children: [
        ZoomIn(
          duration: Duration(milliseconds: 500),
          child: Text(
            userInfo.userName != null
                ? "Welcome na kub ${userInfo.userName}"
                : "D kub",
          ),
        ),
      ],
    );
  }
}
