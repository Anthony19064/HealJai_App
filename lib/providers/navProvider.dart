import 'package:flutter/material.dart';

class Navprovider extends ChangeNotifier {
  int selectedIndex = 2; 

  void setIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void resetHome(){
    selectedIndex = 2;
    notifyListeners();
  }
}