import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String apiURL = dotenv.env['BE_API_URL'] ?? '';

Future<Map<String, dynamic>> addDiaryMood(String? token, String mood) async {
  final response = await http.post(
    Uri.parse('$apiURL/api/addDiaryMood'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'moodValue': mood}),
  );
  final data = jsonDecode(response.body);

  return data;
}

Future<Map<String, dynamic>> addDiaryQuestion(
  String? token,
  String question,
  String answer,
) async {
  final response = await http.post(
    Uri.parse('$apiURL/api/addDiaryQuestion'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'question': question, 'answer': answer}),
  );
  final data = jsonDecode(response.body);

  return data;
}

Future<Map<String, dynamic>> addDiaryStory(
  String? token,
  List<String> storyList,
) async {
  final response = await http.post(
    Uri.parse('$apiURL/api/addDiaryStory'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'storyValue' : storyList,
    }),
  );
  final data = jsonDecode(response.body);

  return data;
}
