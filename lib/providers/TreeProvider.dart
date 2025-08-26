import 'package:flutter/material.dart';
import 'package:healjai_project/service/token.dart';
import 'package:healjai_project/service/tree.dart';

class TreeProvider extends ChangeNotifier {
  int TreeAge = 0;

  Future<void> fetchTreeAge() async {
    String? token = await getJWTToken();

    final age = await getTreeAge(token);
    TreeAge = age ?? 0;
    notifyListeners();
  }

  
}