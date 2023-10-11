import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_provider.dart';

class CharacterProvider with ChangeNotifier {
  Map<String, dynamic>? _currentCharacter = 
    {'name': 'Shiba Inu', 'image': 'assets/images/cute_shiba_inu.png'};

  Map<String, dynamic>? get currentCharacter => _currentCharacter;

  set currentCharacter(Map<String, dynamic>? character) {
    _currentCharacter = character;
    notifyListeners();
  }
}

class ProfileProvider with ChangeNotifier {
  String _userName = '';
  String _joinedAt = '';
  int _dreamCount = 0;

  String get userName => _userName;
  String get joinedAt => _joinedAt;
  int get dreamCount => _dreamCount;

  void setProfileInfo(String userName, String joinedAt, int dreamCount) {
    _userName = userName;
    _joinedAt = joinedAt;
    _dreamCount = dreamCount;
    notifyListeners();
  }

Future<void> fetchProfileInfo() async {
  String? accessToken = await getCurrentUserAccessToken();
  if (accessToken == null) {
    return;
  }

  var backendAddress = dotenv.env['BACKEND_ADDRESS'];
  // Fetch dream count
  var url = Uri.parse('$backendAddress/api/user/user_profile');
  var body = jsonEncode({});

  var response = await http.post(
    url,
    headers: {'Content-Type': 'application/json', 'Authorization': accessToken},
    body: body,
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    setProfileInfo(
      data['user_name'],
      data['joined_at'],
      data['dream_count'],
    );
  } else {
    print("Error found");
    print(response.statusCode);
  }
}

}
