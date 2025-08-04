import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String apiURL = dotenv.env['BE_API_URL'] ?? '';

Future<Map<String, dynamic>> checkMail(String mail) async {
  final response = await http.get(
    Uri.parse('$apiURL/api/checkMail/$mail'),
    headers: {'Content-Type': 'application/json'},
  );

  final data = jsonDecode(response.body);
  return data;
}

Future<Map<String, dynamic>> send_OTP(String email) async {
  final response = await http.post(
    Uri.parse('$apiURL/api/sendOTP'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'mail': email}),
  );

  final data = jsonDecode(response.body);
  return data;
}

Future<Map<String, dynamic>> verify_OTP(String email, String otp) async {
  final response = await http.post(
    Uri.parse('$apiURL/api/verifyOTP'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'mail': email, 'otp': otp}),
  );

  final data = jsonDecode(response.body);
  return data;
}

Future<Map<String, dynamic>> reset_Password(String email, String newPassword) async {
  final response = await http.put(
    Uri.parse('$apiURL/api/ResetPassword'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'mail': email, 'newPassword': newPassword}),
  );

  final data = jsonDecode(response.body);
  return data;
}