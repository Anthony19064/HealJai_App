import 'package:flutter/material.dart';

class ResetProvider extends ChangeNotifier {
  late String mail;

  void setMail(String email){
    mail = email;
    notifyListeners();
  }

}