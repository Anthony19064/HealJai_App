import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healjai_project/service/apiCall.dart';

String apiURL = dotenv.env['BE_API_URL'] ?? '';

Future<int?> getPosts(String? token) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/posts}',
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
