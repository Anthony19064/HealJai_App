import 'package:flutter/material.dart';

class ResetInfo extends ChangeNotifier {
  late String mail;

  void setMail(String email){
    mail = email;
    notifyListeners();
  }

}