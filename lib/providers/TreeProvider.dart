import 'package:flutter/material.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/token.dart';
import 'package:healjai_project/service/tree.dart';

class TreeProvider extends ChangeNotifier {
  int TreeAge = 0;

  Future<void> fetchTreeAge() async {
    final userID = await getUserId();
    if (userID != null) {
      final age = await getTreeAge();
      TreeAge = age ?? 0;
      notifyListeners();
    }
  }
}
