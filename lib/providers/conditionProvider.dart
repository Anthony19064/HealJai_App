import 'package:shared_preferences/shared_preferences.dart';

Future<void> setConditionState() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('conditionState', true);
}

Future<bool> getConditionState() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('conditionState') ?? false;
}