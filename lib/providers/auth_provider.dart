import 'dart:convert';
import 'package:authing_sdk_v3/client.dart';
import 'package:authing_sdk_v3/result.dart';
import '/functions/versions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


// this is for authing only, they unfortunately dont have management for this case 
Future<void> saveAuthResultToStorage(AuthResult authResult) async {
  final storage = const FlutterSecureStorage();
  await storage.write(key: 'authing_id_token', value: authResult.data['id_token']);
  await storage.write(key: 'authing_id_expires_in', value: authResult.data['expires_in'].toString());
  // then also save the expiration
  print("saved to local storage");
}

Future<String?> getAuthingResultFromStorage() async {
  final storage = FlutterSecureStorage();
  String? idToken = await storage.read(key: 'authing_id_token');
  String? expiresIn = await storage.read(key: 'authing_id_expires_in');
  

  if (idToken == null) {
    return null;
  }
  print("loaded access token form local storage");
  print(idToken);
  return idToken;
}

// this is also a binary case, access token can come from either Authing or firebase 
Future<String?> getCurrentUserAccessToken() async {
  String accessToken;
    print("get access token from firebase");
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return null;
    } else {
      print(currentUser.uid);
      String accessToken = await currentUser.getIdToken();
      return accessToken;
    }
}

Future<String?> logoutCurrentUser() async {
  await FirebaseAuth.instance.signOut();
}

