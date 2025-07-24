import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


final GoogleSignIn googleSignIn = GoogleSignIn();

Future<UserCredential?> signInWithGoogle() async {
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