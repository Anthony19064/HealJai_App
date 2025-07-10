import 'package:flutter/material.dart';

import '../Widgets/header_section.dart';
import '../Widgets/bottom_nav.dart';

class CommuScreen extends StatefulWidget {
  const CommuScreen({super.key});

  @override
  State<CommuScreen> createState() => _CommuScreenState();
}

class _CommuScreenState extends State<CommuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HeaderSection(),
            Text("Commu page")
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}