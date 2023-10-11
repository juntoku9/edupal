import 'package:coda_ai/providers/profile_provider.dart';
import 'character_page.dart';
import 'functions/message_utils.dart';
import 'login.dart';
import 'providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

// ... The rest of the imports ...
class _ProfilePageState extends State<ProfilePage> {
  final String profileImageUrl =
      'https://via.placeholder.com/150'; // Replace with actual profile image URL
  String userName = 'Van Gogh';
  String joinedAt = '1853-03-30';
  int dreamCount = 0;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildSocialMediaIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () async {
            // Handle the Discord icon tap
            var url = Uri.parse("https://discord.com/invite/");
            
              if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  print("Could not launch $url");
                  // You can also show an error message to the user using a Snackbar, Dialog, or any other method
                }
          },
          child: Image.asset('assets/images/discord.png', width: 30, height: 30),
        ),
        SizedBox(width: 20),
        InkWell(
          onTap: () async {
            // Handle the Instagram icon tap
            var url = Uri.parse("https://www.instagram.com/");
            
              if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  print("Could not launch $url");
                  // You can also show an error message to the user using a Snackbar, Dialog, or any other method
                }
          },
          child: Image.asset('assets/images/instagram.png', width: 30, height: 30),
        ),
        // SizedBox(width: 20),
        // InkWell(
        //   onTap: () {
        //     // Handle the Twitter icon tap
        //   },
        //   child: Image.asset('assets/icons/twitter.png', width: 40, height: 40),
        // ),
      ],
    );
  }

void _deleteAccount() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Account Deletion'),
            content: Text('Are you sure you want to delete your account?'),
            actions: [
              TextButton(
                onPressed: () async {
                  try{
                    await user.delete();
                    print('User account deleted successfully.');

                    // Redirect to LoginPage and remove all previous routes
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );

                  }
                  catch(e){
                    print('Failed to delete user account: $e');
                    showErrorMessage(context, 'Failed to delete user account: $e');
                  }
                  // Navigator.of(context).pop(); // Close the dialog

                },
                child: Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('No'),
              ),
            ],
          );
        },
      );
    }
  } catch (e) {
    _isDeleting = false;
    print('Failed to delete user account: $e');
    showErrorMessage(context, 'Failed to delete user account: $e');
  }
}

  Widget _buildDeleteButton() {
    return ElevatedButton(
      onPressed: _deleteAccount,
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 32),
        minimumSize: Size(150, 30),
      ),
      child: Text(
        AppLocalizations.of(context)!.deleteMyAccount,
        style: TextStyle(
          fontFamily: 'CuteFont',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black
        ),
      ),
    );
  }

    Widget _buildSelectAvatar() {
    return ElevatedButton(
      onPressed: _deleteAccount,
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 32),
        minimumSize: Size(150, 30),
      ),
      child: Text(
        AppLocalizations.of(context)!.deleteMyAccount,
        style: TextStyle(
          fontFamily: 'CuteFont',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  final characterProvider = context.watch<CharacterProvider>();

  return Scaffold(
    backgroundColor: Colors.grey[100],

    appBar: AppBar(
      title: Text('Settings'),
      backgroundColor: Colors.blueGrey,
      elevation: 0,
    ),

    body: Container(
      padding: EdgeInsets.symmetric(horizontal: 16),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(characterProvider.currentCharacter!['image']),
        ),
          SizedBox(height: 20),
          Text(
            characterProvider.currentCharacter!['name'],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          SizedBox(height: 10),
          // Text(
          //   characterProvider.currentCharacter!['description'],
          //   style: TextStyle(
          //     fontSize: 18,
          //     color: Colors.grey,
          //   ),
          // ),
          SizedBox(height: 30),
          _buildSocialMediaIcons(),
          SizedBox(height: 20),
          buildStyledButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CharacterPage()));
          },
            label: "Select Character",
            primaryColor: Colors.white,
            textColor: Colors.black
          ),
          SizedBox(height: 20),
          buildStyledButton(
            onPressed: _deleteAccount,
            label: AppLocalizations.of(context)!.deleteMyAccount,
            primaryColor: Colors.white,
            textColor: Colors.black
          ),
          SizedBox(height: 20),
          buildStyledButton(
            onPressed: () async {
              try {
                await logoutCurrentUser();
                print("User signed out successfully.");
              } catch (e) {
                // showErrorMessage(context, "Error signing out: $e");
              }
              Navigator.pushNamed(context, '/');
            },
            label: AppLocalizations.of(context)!.logout,
            primaryColor: Colors.white,
            textColor: Colors.black
          ),
          SizedBox(height: 50),
        ],
      ),
    ),
  );
}

Widget buildStyledButton({required VoidCallback onPressed, required String label, required Color primaryColor, required Color textColor}) {
  return Container(
    width: double.infinity,
    height: 50,  // Consistent height for the button
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: primaryColor,
        onPrimary: textColor,
        shadowColor: Colors.grey[50],
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'CuteFont',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
}