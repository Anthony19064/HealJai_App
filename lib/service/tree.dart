import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String apiURL = dotenv.env['BE_API_URL'] ?? '';

Future<int?> getTreeAge(String? token) async {
  final response = await http.get(
    Uri.parse('$apiURL/api/getAge'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final data = jsonDecode(response.body);
  if (data['success'] == true) {
    return data['data']['treeAge'] as int;
  } else {
    print("Error: ${response.statusCode}, ${response.body}");
    return null;
  }
}

Future<Map<String, dynamic>?> addAge(String? token, int day, int month, int year) async {
  final response = await http.post(
    Uri.parse('$apiURL/api/addAge/${day}/${month}/${year}'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final data = jsonDecode(response.body);
  if (data['success'] == true) {
    return data;
  } else {
    print("Error: ${response.statusCode}, ${response.body}");
    return null;
  }
}
