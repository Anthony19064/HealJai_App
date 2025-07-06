import 'package:flutter/material.dart';

class TestBody extends StatefulWidget {
  const TestBody({super.key});

  @override
  State<TestBody> createState() => _TestBodyState();
}

class _TestBodyState extends State<TestBody> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Hello HealJai App'),
        ],
      ),
    );
  }
}