import 'package:flutter/material.dart';
import 'package:healjai_project/service/authen.dart';

class UserProvider extends ChangeNotifier {
  static final UserProvider _instance = UserProvider._internal(); // instance เดียว
  factory UserProvider() => _instance; // เรียกใช้ผ่าน factory

  UserProvider._internal() {
    setUserInfo(); // โหลด user info ตอนสร้างครั้งแรก
  }

  String? userId;
  String? userName;
  String? userMail;
  String? userPhoto;

  bool get isLoggedIn => userId != null;

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
