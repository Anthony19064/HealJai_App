import 'package:flutter/material.dart';
import 'package:healjai_project/service/authen.dart';

class UserProvider extends ChangeNotifier {
  String? userId;
  String? userName;
  String? userMail;
  String? userPhoto;

  UserProvider() {
    setUserInfo();
  }

  bool get isLoggedIn => userId != null; // ✅ getter ไว้เช็คง่าย ๆ

  Future<void> setUserInfo() async {
    final data = await getUserLocal();
    userId = data['userId'];
    userName = data['userName'];
    userMail = data['userMail'];
    userPhoto = data['userPhoto'];
    notifyListeners();
  }

  Future<void> clearUserInfo() async {
    userId = null;
    userName = null;
    userMail = null;
    userPhoto = null;
    notifyListeners();
  }
}
