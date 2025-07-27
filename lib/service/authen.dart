import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


final GoogleSignIn googleSignIn = GoogleSignIn();
String apiURL = dotenv.env['BE_API_URL'] ?? '';

Future<Map<String, dynamic>> signInwithEmail(String email, String password) async{
  final response = await http.post(
    Uri.parse('$apiURL/api/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'mail' : email,
      'password' : password,
    }),
  );
  final data = jsonDecode(response.body);

  if (response.statusCode == 200 && data['success'] == true) {
    return data;
  }else{
    print("Error API ${data['message']}");
    return {};
  }

}

Future<UserCredential?> signInWithGoogle() async{
  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null; // User canceled

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    print('Error during Google sign in: $e');
    return null;
  }
}


Future<void> saveUserToLocal(Map<String, dynamic> user) async{
  final prefs = await SharedPreferences.getInstance(); // instance Local

  await prefs.setString('userId', user['userId']?? '');
  await prefs.setString('userName', user['userName']?? '');
  await prefs.setString('userMail', user['userMail']?? '');
  await prefs.setString('userPhoto', user['userPhoto']?? '');
}


Future<Map<String, String?>> getUserLocal() async{
  final prefs = await SharedPreferences.getInstance(); // instance Local

  final id = prefs.getString('userId');
  final name = prefs.getString('userName');
  final mail = prefs.getString('userMail');
  final photo = prefs.getString('userPhoto');

  

  return {
    'userName' : name,
    'userId' : id,
    'userMail' : mail,
    'userPhoto' : photo,
  };
  
}

Future<void> clearUserLocal () async{
  // Google
  if (await googleSignIn.isSignedIn()) {
    await googleSignIn.signOut();
  }

  // Local
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  print(" logout หมดแล้วจ้า ✅");
}