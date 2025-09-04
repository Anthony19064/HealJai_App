import 'package:flutter/material.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/tree.dart';

class TreeProvider extends ChangeNotifier {
  int TreeAge = 0;

  Future<void> fetchTreeAge() async {
    bool? loginState = await isUserLoggedin();
    if (loginState) {
      final age = await getTreeAge();
      TreeAge = age ?? 0;
      notifyListeners();
    }
  }

  Future<void> clearTree() async{
    TreeAge = 0;
    notifyListeners();
  }
}
