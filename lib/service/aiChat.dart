import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healjai_project/service/apiCall.dart';

String apiURL = dotenv.env['BE_API_URL'] ?? '';


Future<Map<String, dynamic>> SendChatToAi(List<Map<String, String>> logChat) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/ask',
    method: 'POST',
    body: {'logChat' : logChat}
  );
  final data = jsonDecode(response.body);
  return data;
}
