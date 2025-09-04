import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healjai_project/service/apiCall.dart';
import 'package:healjai_project/service/token.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final GoogleSignIn googleSignIn = GoogleSignIn();
String apiURL = dotenv.env['BE_API_URL'] ?? '';

Future<Map<String, dynamic>> signInwithEmail(
  String email,
  String password,
) async {
  final response = await http.post(
    Uri.parse('$apiURL/api/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'mail': email, 'password': password}),
  );
  final data = jsonDecode(response.body);

  return data;
}

Future<Map<String, dynamic>> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      final response = await http.post(
        Uri.parse('$apiURL/api/googleAuth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'displayName': user?.displayName,
          'email': user?.email,
          'uid': user?.uid,
          'photoURL': user?.photoURL,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    }
    return {};
  } catch (e) {
    print('Error during Google Sign-In: $e');
    return {};
  }
}

Future<void> logout() async {
  final userID = await getUserId();
  final response = await http.post(
    Uri.parse('$apiURL/api/logout'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'userId': userID}),
  );
  final data = jsonDecode(response.body);
  if (data['success'] == true) {
    await clearUserLocal(); // clear local
    await deleteJWTAcessToken();
    deleteJWTRefreshToken();
  }
}

Future<Map<String, dynamic>> register(
  String username,
  String email,
  String password,
  String confirmPassword,
) async {
  final response = await http.post(
    Uri.parse('$apiURL/api/regis'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': username,
      'mail': email,
      'password': password,
      'confirmPassword': confirmPassword,
    }),
  );
  final data = jsonDecode(response.body);
  return data;
}

Future<void> saveUserToLocal(Map<String, dynamic> user) async {
  final prefs = await SharedPreferences.getInstance(); // instance Local

  await prefs.setString('userId', user['userId'] ?? '');
  await prefs.setString('userName', user['userName'] ?? '');
  await prefs.setString('userMail', user['userMail'] ?? '');
  await prefs.setString('userPhoto', user['userPhoto'] ?? '');
}

Future<Map<String, String?>> getUserLocal() async {
  final prefs = await SharedPreferences.getInstance(); // instance Local

  final id = prefs.getString('userId');
  final name = prefs.getString('userName');
  final mail = prefs.getString('userMail');
  final photo = prefs.getString('userPhoto');

  return {'userName': name, 'userId': id, 'userMail': mail, 'userPhoto': photo};
}

Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance(); // instance Local
  return prefs.getString('userId');
}

Future<void> clearUserLocal() async {
  // Google
  if (await googleSignIn.isSignedIn()) {
    await googleSignIn.signOut();
  }

  // Local
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('userId');
  await prefs.remove('userName');
  await prefs.remove('userMail');
  await prefs.remove('userPhoto');
  await prefs.remove('JWT_Token');

  print(" logout หมดแล้วจ้า ✅");
}

Future<bool> isUserLoggedin() async {
  final prefs = await SharedPreferences.getInstance();
  final id = prefs.getString('userId');

  return id != null;
}
