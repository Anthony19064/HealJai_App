import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:healjai_project/providers/userProvider.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/token.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

//ฟังก์ชั่น Call Api และ refreshToken ในตัว
Future<http.Response> requestWithTokenRetry(
  String url, {
  required String method,
  dynamic body,
  required BuildContext context,
}) async {
  final userProvider = Provider.of<UserProvider>(context);
  Future<http.Response> callApi() async {
    String? token = await getJWTAcessToken();
    if (method == 'GET') {
      return await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } else if (method == 'POST') {
      return await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body != null ? jsonEncode(body) : null,
      );
    } else if (method == 'DELETE') {
      return await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } else if (method == 'PUT') {
      return await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body != null ? jsonEncode(body) : null,
      );
    } else {
      throw Exception('Method $method not supported');
    }
  }

  http.Response response = await callApi();

  if (response.statusCode == 401) {
    final status = await refreshToken(); // refresh token + save access
    if (status == "ResetSuccess") {
      response = await callApi(); // retry
    }
    if (status == "Token expired") {
      await deleteJWTRefreshToken();
      await deleteJWTAcessToken();
      await clearUserLocal();
      userProvider.clearUserInfo();
    }
  }

  return response;
}
