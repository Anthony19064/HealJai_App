import 'package:flutter/material.dart';

class NavState extends ChangeNotifier {
  int selectedIndex = 2; 

  void setIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}