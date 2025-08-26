import 'package:flutter/material.dart';
import 'package:healjai_project/service/diaryFeture.dart';
import 'package:healjai_project/service/token.dart';
import 'package:healjai_project/service/tree.dart';

class DiaryProvider extends ChangeNotifier {
  int totalTask = 3;
  int taskCount = 0;
  double taskPercent = 0.00; // 0.00 ถึง 1

  bool mood = false;
  bool question = false;
  bool story = false;

  Future<void> fetchTaskCount() async {
    DateTime toDay = DateTime.now();
    String? token = await getJWTToken();
    int day = toDay.day;
    int month = toDay.month;
    int year = toDay.year;
    taskCount = await getTaskCount(token, day, month, year) ?? 0;
    taskPercent = taskCount / totalTask;
    if (taskCount == 3) {
      await addAge(token, day, month, year);
    }
    
    notifyListeners();
  }
}
