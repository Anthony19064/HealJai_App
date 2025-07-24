import 'package:flutter/material.dart';

import '../Widgets/header_section.dart';

class CommuScreen extends StatefulWidget {
  const CommuScreen({super.key});

  @override
  State<CommuScreen> createState() => _CommuScreenState();
}

class _CommuScreenState extends State<CommuScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Commu page"),
      ],
    );
  }
}