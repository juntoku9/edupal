import 'dart:convert';

import 'package:authing_sdk_v3/client.dart';
import 'package:authing_sdk_v3/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'functions/versions.dart';
import 'homepage.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';

import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'providers/profile_provider.dart';
import 'functions/message_utils.dart';
import 'login_page.dart';

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// convert user profile to json 
// todo: potentially dangeraous 
// Map<String, dynamic> userProfileToJson(UserProfile userProfile) {
//   return {
//     'sub': userProfile.sub,
//     'name': userProfile.name,
//     'givenName': userProfile.givenName,
//     'familyName': userProfile.familyName,
//     'middleName': userProfile.middleName,
//     'email': userProfile.email,
//     'profileUrl': userProfile.profileUrl?.toString(),
//     'gender': userProfile.gender,
//     // 'birthdate': userProfile.birthdate,
//     'zoneinfo': userProfile.zoneinfo,
//     'locale': userProfile.locale,

//   };
// }
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {  
  final ValueNotifier<bool> _loginCheckComplete = ValueNotifier<bool>(false);
  final providers = [EmailAuthProvider()];


  @override
  void initState() {
    super.initState();
    // check the update first 

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try{
        final isUpToDate = await checkBackendVersion(context, onLaterPressed: () {
          print("check version result");
          checkUserLoggedIn();
        });
        
        if (isUpToDate) {
          print("only check if it is up to date");
          //if not, the above is blocking
          checkUserLoggedIn();
        }
        else{
          // no op
          showErrorMessage(context, "error: version check result hanging...");
        }
      } 
      catch (e) {
        print(e);
        showErrorMessage(context, e.toString());
        // login still possible
        checkUserLoggedIn();
      }
      
    });
  }

  Future<void> checkUserLoggedIn() async {
      // Check if the user is already logged in
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user != null) {
          print("user is logged in ");
          try{
            print("going to create the user");
            await createUser();
          }
          catch (e) {
            print(e);
            showErrorMessage(context, "create user failed "+ e.toString());
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        } else {
          _loginCheckComplete.value = true;
        }
      });
  }
  
    Future<void> createUser() async {
    // do not create user for now 
    return;
    // final credentials = await auth0.credentialsManager.credentials();
    String? accessToken = await getCurrentUserAccessToken();
    if (accessToken == null) {
      showErrorDialog(context, "Encountered Error", "Please login to use this feature");
      return;
    }
    var url = Uri.parse('${dotenv.env['BACKEND_ADDRESS']}/api/user/create');
    // just give the entire user for credentials 
    var body = jsonEncode({});

    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': accessToken},
      body: body,
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);

    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

  }


  @override
  Widget build(BuildContext context) {
  Future<String> loadTermsOfService() async {
    return await rootBundle.loadString('assets/resource/terms.md');
  }

    return Scaffold(
      body: Container(
        // decoration: const BoxDecoration(
        //   image: DecorationImage(
        //     image: ExactAssetImage('assets/images/login_cover.png'),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/app_logo.png',
              height: 120,
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.welcomeQuote,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: _loginCheckComplete, 
                builder: (context, isCheckComplete, child) {
                  if (!isCheckComplete) {
                    // Show a CircularProgressIndicator while checking the login status
                    return Center(child: CircularProgressIndicator());
                  }
                    return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: ElevatedButton(
                            onPressed: () async {
                              // auth0.webAuthentication(scheme: "myapp").logout();
                              // should directly add the auth here   
                              // source : https://pub.dev/packages/firebase_ui_auth
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => 
                              // SignInPage()
                              SignInScreen()
                              ), 
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.login,
                              style: TextStyle(
                                color: Color(0xFF002C7F),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'By signing in, you agree to our ',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                                String termsOfServiceContent = await loadTermsOfService();
                                showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Terms of Service'),
                                    content: SingleChildScrollView(
                                      child: SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.6,
                                        width: MediaQuery.of(context).size.width * 0.9,
                                      child: Markdown(
                                        data: termsOfServiceContent,
                                      ),
                                    ),

                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Close'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                }
                              );
                            },
                            child: const Text(
                              'Terms of Service',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      )]);
                },
            ),          // Add the FutureBuilder for the version string here
          FutureBuilder<String>(
            future: getCurrentAppVersion(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    'App Version: ${snapshot.data}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
          ],
        ),
        
      ),
    );
  }
}
