import 'package:flutter/material.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/tree.dart';

class TrackerProvider extends ChangeNotifier {
  int TrackerDay = 0;

  Future<void> fetchTreeAge() async {
    bool? loginState = await isUserLoggedin();
    if (loginState) {
      final age = await getTrackerDay();
      TrackerDay = age ?? 0;
      notifyListeners();
    }
  }

  Future<void> clearTree() async{
    TrackerDay = 0;
    notifyListeners();
  }
}
