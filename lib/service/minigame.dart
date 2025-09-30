import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healjai_project/service/apiCall.dart';

String apiURL = dotenv.env['BE_API_URL'] ?? '';

Future<Map<String, dynamic>> getQuote(String userID) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/MinigameScore/$userID',
    method: 'GET',
  );
  final data = jsonDecode(response.body);
  if (data['success']) {
    return data;
  }
  return {};
}

Future<Map<String, dynamic>> getLeaderBoard() async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/LeaderBoard',
    method: 'GET',
  );
  final data = jsonDecode(response.body);
  if (data['success']) {
    return data;
  }
  return {};
}
