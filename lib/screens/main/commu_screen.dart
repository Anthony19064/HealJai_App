import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

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
        ZoomIn(
          duration: Duration(milliseconds: 500),
          child: Text("Commu page"),
        ),
      ],
    );
  }
}
