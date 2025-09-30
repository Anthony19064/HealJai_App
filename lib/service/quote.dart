import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healjai_project/service/apiCall.dart';

String apiURL = dotenv.env['BE_API_URL'] ?? '';

Future<List<Map<String, dynamic>>> getQuote(String type) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/quote/$type',
    method: 'GET',
  );
  final data = jsonDecode(response.body);
  if (data['success']) {
    return List<Map<String, dynamic>>.from(data['data']);
  }
  return [];
}

Future<Map<String, dynamic>> addQuoteLike(String userId, String quoteId) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/quoteLikes',
    method: 'POST',
    body: {'userID': userId, 'quoteID': quoteId},
  );
  final data = jsonDecode(response.body);
  return data;
}


Future<Map<String, dynamic>> addQuoteBookmark(String userId, String quoteId) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/quoteBookmark',
    method: 'POST',
    body: {'userID': userId, 'quoteID': quoteId},
  );
  final data = jsonDecode(response.body);
  return data;
}

Future<Map<String, dynamic>> getStateQuoteLike(String userId, String quoteId) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/quoteLikes/$userId/$quoteId',
    method: 'GET',
  );
  final data = jsonDecode(response.body);
  return data;
}

Future<Map<String, dynamic>> getStateQuoteBookmark(String userId, String quoteId) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/quoteBookmark/$userId/$quoteId',
    method: 'GET',
  );
  final data = jsonDecode(response.body);
  return data;
}

Future<List<Map<String, dynamic>>> getMyquoteBookmark(String userID) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/quoteBookmarkLst/$userID',
    method: 'GET',
  );
  final data = jsonDecode(response.body);
  return List<Map<String, dynamic>>.from(data['data']);
}