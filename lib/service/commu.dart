import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healjai_project/service/apiCall.dart';
import 'package:firebase_storage/firebase_storage.dart';

String apiURL = dotenv.env['BE_API_URL'] ?? '';

Future<String?> uploadImage(File? file) async {
  if (file == null) return '';
  try {
    final ref = FirebaseStorage.instance
        .ref()
        .child('PostIMG/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(file);

    // ดึงลิงก์ดาวน์โหลดกลับมา
    return await ref.getDownloadURL();
  } catch (e) {
    print("Upload error: $e");
    return null;
  }
}

Future<List<Map<String, dynamic>>> getPosts() async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/posts',
    method: 'GET',
  );
  final data = jsonDecode(response.body);
  return List<Map<String, dynamic>>.from(data['data']);
}

Future<Map<String, dynamic>?> addPost(String? userId, String postText, String? imgPath) async {
  final response = await requestWithTokenRetry(
    '$apiURL/api/posts',
    method: 'POST',
    body: {'userID': userId, 'infoPost': postText, 'imgUrl': imgPath},
  );
  final data = jsonDecode(response.body);
  return data;
}
