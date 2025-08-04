import 'package:flutter/material.dart';
import 'package:healjai_project/service/authen.dart';

class UserInfo extends ChangeNotifier {
  String? userId;
  String? userName;
  String? userMail;
  String? userPhoto;

  UserInfo() {
    setUserInfo();
  }

  Future<void> setUserInfo() async {
    final data = await getUserLocal();
    userId = data['userId'];
    userName = data['userName'];
    userMail = data['userMail'];
    userPhoto = data['userPhoto'];
    notifyListeners();
  }

  Future<void> clearUserInfo() async{
    userId = null;
    userName = null;
    userMail = null;
    userPhoto = null;
    notifyListeners();
  }
  
}
