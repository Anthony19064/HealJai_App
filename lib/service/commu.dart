import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healjai_project/service/apiCall.dart';
import 'package:firebase_storage/firebase_storage.dart';

String apiURL = dotenv.env['BE_API_URL'] ?? '';

Future<String?> uploadImage(File? file) async {
  if (file == null) return '';
  try {
    final ref = FirebaseStorage.instance.ref().child(
      'PostIMG/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await ref.putFile(file);

    // ดึงลิงก์ดาวน์โหลดกลับมา
    return await ref.getDownloadURL();
  } catch (e) {
    print("Upload error: $e");
    return null;
  }
}

Future<List<Map<String, dynamic>>> getPosts(int page, int limit) async {
  final skip = page * limit;
  final response = await requestWithTokenRetry(
    '$apiURL/api/posts?skip=$skip&limit=$limit',
    method: 'GET',
  );
  final data = jsonDecode(response.body);
  return List<Map<String, dynamic>>.from(data['data']);
}

Future<Map<String, dynamic>?> addPost(
  String? userId,
  String postText,
  String? imgPath,
) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/posts',
    method: 'POST',
    body: {'userID': userId, 'infoPost': postText, 'imgUrl': imgPath},
  );
  final data = jsonDecode(response.body);
  return data;
}

Future<Map<String, dynamic>> deletePost(String postID) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/posts/$postID',
    method: 'DELETE',
  );
  final data = jsonDecode(response.body);
  return data;
}

Future<Map<String, dynamic>> updatePost(
  String postID,
  Map<String, dynamic> newData,
) async {
  print(newData);
  final response = await requestWithTokenRetry(
    '$apiURL/api/posts/$postID',
    method: 'PUT',
    body: {'newData': newData},
  );
  final data = jsonDecode(response.body);
  return data;
}

Future<int> getCountLike(String postId) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/countLike/$postId',
    method: 'GET',
  );
  final data = jsonDecode(response.body);
  final countLike = data['data'];
  return countLike;
}

Future<Map<String, dynamic>> addLike(String? postId, String? userId) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/Like',
    method: 'POST',
    body: {'postID': postId, 'userID': userId},
  );
  final data = jsonDecode(response.body);
  return data;
}

Future<Map<String, dynamic>> getStateLike(
  String? postId,
  String? userId,
) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/Like/$postId/$userId',
    method: 'GET',
  );
  final data = jsonDecode(response.body);
  return data;
}

Future<List<Map<String, dynamic>>> getComments(String postId) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/Comment/$postId',
    method: 'GET',
  );
  final data = jsonDecode(response.body);
  return List<Map<String, dynamic>>.from(data['data']);
}

Future<int> getCountComment(String postId) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/countComment/$postId',
    method: 'GET',
  );
  final data = jsonDecode(response.body);
  final countComment = data['data'];
  return countComment;
}

Future<Map<String, dynamic>> addComment(
  String postId,
  String userId,
  String commentTxt,
) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/Comment',
    method: 'POST',
    body: {'postID': postId, 'userId': userId, 'commentInfo': commentTxt},
  );
  final data = jsonDecode(response.body);
  if (data['success']) {
    return data;
  }
  return {};
}
