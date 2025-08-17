import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

AndroidOptions _getAndroidOptions() =>
    const AndroidOptions(encryptedSharedPreferences: true);

final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

Future<void> saveJWTToken(String token) async {
  await storage.delete(key: 'jwt_token');
  await storage.write(key: 'jwt_token', value: token);
}

Future<void> deleteJWTToken() async {
  await storage.delete(key: 'jwt_token');
}

Future<String?> getJWTToken() async {
  String? token = await storage.read(key: 'jwt_token');
  return token;
}

Future<bool> checkToken(BuildContext context, int statusCode) async {
  if (statusCode == 401 || statusCode == 403) {
    await storage.delete(key: 'jwt_token');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Session หมดอายุ กรุณาเข้าสู่ระบบใหม่')),
    );
    Navigator.pushReplacementNamed(context, '/login');
    return false;
  }
  return true;
}
