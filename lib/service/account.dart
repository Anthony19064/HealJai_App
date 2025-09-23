import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healjai_project/service/apiCall.dart';

String apiURL = dotenv.env['BE_API_URL'] ?? '';

Future<Map<String, dynamic>> getuserById(String userId) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/Account/$userId',
    method: 'GET',
  );
  final data = jsonDecode(response.body);
  if(data['success']){
    return data['data'];
  }
  return {};
}
