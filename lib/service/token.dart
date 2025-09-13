import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:http/http.dart' as http;

String apiURL = dotenv.env['BE_API_URL'] ?? '';

AndroidOptions _getAndroidOptions() =>
    const AndroidOptions(encryptedSharedPreferences: true);

IOSOptions _getIOSOptions() =>
    const IOSOptions(accessibility: KeychainAccessibility.first_unlock);

final storage = FlutterSecureStorage(aOptions: _getAndroidOptions(), iOptions: _getIOSOptions());

Future<void> saveJWTAccessToken(String token) async {
  await storage.delete(key: 'jwt_accessToken');
  await storage.write(key: 'jwt_accessToken', value: token);
}

Future<void> deleteJWTAcessToken() async {
  await storage.delete(key: 'jwt_accessToken');
}

Future<String?> getJWTAcessToken() async {
  String? token = await storage.read(key: 'jwt_accessToken');
  return token;
}

Future<void> saveJWTRefreshToken(String token) async {
  await storage.delete(key: 'jwt_refreshToken');
  await storage.write(key: 'jwt_refreshToken', value: token);
}

Future<void> deleteJWTRefreshToken() async {
  await storage.delete(key: 'jwt_refreshToken');
}

Future<String?> getJWTRefreshToken() async {
  String? token = await storage.read(key: 'jwt_refreshToken');
  return token;
}

Future<String> refreshToken() async {
  late String status;
  final refreshToken = await getJWTRefreshToken();
  String userID = await getUserId();
  final response = await http.post(
    Uri.parse('$apiURL/api/refreshToken'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'refreshToken': refreshToken, 'userID': userID}),
  );


  if (response.statusCode == 401) {
    status =  "Token expired";
  }
  if (response.statusCode == 500) {
    status = "Server Error";
  }

  final data = jsonDecode(response.body);
  if (data['success'] == true) {
    await saveJWTAccessToken(data['accessToken']);
    status = "ResetSuccess";

  }

  return status;

  
}
