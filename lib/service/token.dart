import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

String apiURL = dotenv.env['BE_API_URL'] ?? '';

AndroidOptions _getAndroidOptions() =>
    const AndroidOptions(encryptedSharedPreferences: true);

final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

Future<void> saveJWTAccessToken(String token) async {
  await storage.delete(key: 'jwt_accessTcoken');
  await storage.write(key: 'jwt_accessTcoken', value: token);
}

Future<void> deleteJWTAcessToken() async {
  await storage.delete(key: 'jwt_accessTcoken');
}

Future<String?> getJWTAcessToken() async {
  String? token = await storage.read(key: 'jwt_accessTcoken');
  return token;
}

Future<void> saveJWTRefreshToken(String token) async {
  await storage.delete(key: 'jwt_refreshTcoken');
  await storage.write(key: 'jwt_refreshTcoken', value: token);
}

Future<void> deleteJWTRefreshToken() async {
  await storage.delete(key: 'jwt_refreshTcoken');
}

Future<String?> getJWTRefreshToken() async {
  String? token = await storage.read(key: 'jwt_refreshTcoken');
  return token;
}

Future<String> refreshToken() async {
  final refreshToken = await getJWTRefreshToken();
  final response = await http.post(
    Uri.parse('$apiURL/api/refreshToken'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'refreshToken': refreshToken}),
  );


  if (response.statusCode == 401) {
    return "Token expired";
  }
  if (response.statusCode == 500) {
    return "Server Error";
  }

  final data = jsonDecode(response.body);
  if (data['success'] == true) {
    print('asoidjoiawjd9qKUYYYYYYY');
    await saveJWTAccessToken(data['accessToken']);
  }
  return "ResetSuccess";

  
}
