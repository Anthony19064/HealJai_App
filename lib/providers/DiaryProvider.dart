import 'package:flutter/material.dart';
import 'package:healjai_project/service/authen.dart';
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

  Future<void> fetchTaskCount(BuildContext context) async {
    bool? loginState = await isUserLoggedin();
    if (loginState) {
      DateTime toDay = DateTime.now();
      int day = toDay.day;
      int month = toDay.month;
      int year = toDay.year;
      taskCount = await getTaskCount(context, day, month, year) ?? 0;
      taskPercent = taskCount / totalTask;
      if (taskCount == 3) {
        await addAge(context, day, month, year);
      }

      notifyListeners();
    }
  }

  Future<void> clearTask() async {
    taskCount = 0;
    taskPercent = 0.00;
    notifyListeners();
  }
}
