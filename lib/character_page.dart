import 'functions/message_utils.dart';
import 'login.dart';
import 'providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'providers/profile_provider.dart';

class CharacterPage extends StatefulWidget {
  CharacterPage({Key? key}) : super(key: key);

  @override
  _CharacterPageState createState() => _CharacterPageState();
}

// ... The rest of the imports ...
class _CharacterPageState extends State<CharacterPage> {
  List<Map<String, dynamic>> characters = [
    {'name': 'Shiba Inu', 'image': 'assets/characters/cute_shiba_inu.png'},
    {'name': 'Stray Cat', 'image': 'assets/characters/stray_cat.png'},
    //... Add as many characters as you want
  ];
  Map<String, dynamic>? currentCharacter;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
  final characterProvider = context.watch<CharacterProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Characters'),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            if (characterProvider.currentCharacter != null)
              ListTile(
                title: Text('Current Character: ${characterProvider.currentCharacter!['name']}'),
                leading: Image.asset(characterProvider.currentCharacter!['image']),
              ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: characters.length,
                itemBuilder: (context, index) => CharacterCard(
                  character: characters[index],
                  onTap: () {
                    print("going to change the current character");
                    characterProvider.currentCharacter = characters[index];
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CharacterCard extends StatelessWidget {
  final Map<String, dynamic> character;
  final VoidCallback onTap;

  CharacterCard({required this.character, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final characterProvider = Provider.of<CharacterProvider>(context, listen: false);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Image.asset(character['image'])),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(character['name']),
            ),
          ],
        ),
      ),
    );
  }
}
