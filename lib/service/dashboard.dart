import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healjai_project/service/apiCall.dart';

String apiURL = dotenv.env['BE_API_URL'] ?? '';

Future<Map<String, dynamic>?> ReportPost(
  String userId_sender,
  String userId_reciver,
  String postId,
  String type,
  String feature,
  String detail,
) async {
  final response = await requestWithTokenRetry(
    '$apiURL/admin/dashboardPosts',
    method: 'POST',
    body: {
      'userID_sender': userId_sender,
      'userID_reciver': userId_reciver,
      'postId' : postId,
      'type': type,
      'feature': feature,
      'detail': detail,
    },
  );
  final data = jsonDecode(response.body);
  return data;
}
Future<Map<String, dynamic>?> ReportChat(
  String userId_sender,
  String? roomId,
  String? type,
  String feature,
  String detail,
) async {
  final response = await requestWithTokenRetry(
    '$apiURL/admin/dashboardsChats',
    method: 'POST',
    body: {
      'userID_sender': userId_sender,
      'roomID': roomId,
      'type': type,
      'feature': feature,
      'detail': detail,
    },
  );
  final data = jsonDecode(response.body);
  return data;
}
