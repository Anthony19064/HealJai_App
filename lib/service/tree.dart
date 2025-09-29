import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healjai_project/service/apiCall.dart';

String apiURL = dotenv.env['BE_API_URL'] ?? '';

Future<int?> getTrackerDay() async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/getAge',
    method: 'GET',
  );
  final data = jsonDecode(response.body);
  if (data['success'] == true) {
    return data['data']['treeAge'] as int;
  } else {
    print("Error: ${response.statusCode}, ${response.body}");
    return null;
  }
}

Future<Map<String, dynamic>?> increaseDay(int day, int month, int year) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/addAge/${day}/${month}/${year}',
    method: 'POST',
  );

  final data = jsonDecode(response.body);
  if (data['success'] == true) {
    return data;
  } else {
    print("Error: ${response.statusCode}, ${response.body}");
    return null;
  }
}
