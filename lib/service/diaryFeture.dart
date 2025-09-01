import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healjai_project/service/apiCall.dart';
import 'package:http/http.dart' as http;

String apiURL = dotenv.env['BE_API_URL'] ?? '';

Future<int?> getTaskCount(String? token, int day, int month, int year) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/getTask/${day}/${month}/${year}',
    method: 'GET',
  );
  final data = jsonDecode(response.body);
  if (data['success'] == true) {
    return data['data'] as int;
  } else {
    print("Error: ${response.statusCode}, ${response.body}");
    return null;
  }
}

Future<Map<String, dynamic>?> diaryInfo(
  String? token,
  int day,
  int month,
  int year,
) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/getDiary/${day}/${month}/${year}',
    method: 'GET',
  );
  final data = jsonDecode(response.body);
  if (data['success'] == true) {
    return data['data'];
  } else {
    print("Error: ${response.statusCode}, ${response.body}");
    return null;
  }
}

Future<List<DateTime>> diaryHistory(String? token, int year, int month) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/DiaryHistory/${year}/${month}',
    method: 'GET',
  );
  final Map<String, dynamic> data = jsonDecode(response.body);

  if (data['success'] == true && data['dates'] != null) {
    final List<dynamic> dates = data['dates'];
    // แปลง List<String> เป็น List<DateTime>
    return dates.map<DateTime>((dateStr) => DateTime.parse(dateStr)).toList();
  } else {
    throw Exception('Failed to load diary history');
  }
}

Future<Map<String, dynamic>> addDiaryMood(
  String? token,
  String mood,
  String text,
) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/addDiaryMood',
    method: 'POST',
    body: {'moodValue': mood, 'textUser': text},
  );
  final data = jsonDecode(response.body);
  return data;
}

Future<Map<String, dynamic>> addDiaryQuestion(
  String? token,
  String question,
  String answer,
) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/addDiaryQuestion',
    method: 'POST',
    body: {'userQuestion': question, 'userAnswer': answer},
  );
  final data = jsonDecode(response.body);
  return data;
}

Future<Map<String, dynamic>> addDiaryStory(
  String? token,
  List<String> storyList,
) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/addDiaryStory',
    method: 'POST',
    body: {'storyValue': storyList}
  );
  final data = jsonDecode(response.body);
  return data;
}
