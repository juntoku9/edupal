import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sign_button/sign_button.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoginMode = true;
  void _toggleLoginSignupMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  Future<void> _resetPasswordDialog(BuildContext context) async {
    TextEditingController resetEmailController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap the button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: resetEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Send Reset Link'),
              onPressed: () async {
                try {
                  print(resetEmailController.text);
                  await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: resetEmailController.text);
                  Navigator.of(context).pop();
                } on FirebaseAuthException catch (e) {
                  print('Error sending password reset email: ${e.code}');
                  // Show an error message to the user
                } catch (e) {
                  print('Error: $e');
                  // Show a generic error message to the user
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> createEmailAccount() async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    print("after google login");
    // Once signed in, return the UserCredential
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Login successful! Redirecting...'),
      duration: Duration(seconds: 2),
    ),
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

Future<UserCredential?> signInWithApple() async {
  final appleProvider = AppleAuthProvider();
  if (kIsWeb) {
    await FirebaseAuth.instance.signInWithPopup(appleProvider);
  } else {
    final creds = await FirebaseAuth.instance.signInWithProvider(appleProvider);
    print("login with apple success");
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Login successful! Redirecting...'),
      duration: Duration(seconds: 2),
    ),
    );

  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Dark blue-greyish color
      appBar: AppBar(
        title: Text('Sign In'),
        backgroundColor: Color.fromARGB(255, 169, 174, 183), // Grey-mauve morandi color
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to Dreamore AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            Spacer(flex: 2),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(height: 8),
            if (_isLoginMode)
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {
                    _resetPasswordDialog(context);
                  },
                  hoverColor: Colors.transparent,
                  child: Text.rich(
                    TextSpan(
                      text: 'Forgot password?',
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                      recognizer: TapGestureRecognizer()..onTap = () => _resetPasswordDialog(context),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _isLoginMode ?  signInWithEmailAndPassword(): createEmailAccount();
                },
                child: Text(_isLoginMode ? 'Log In' : 'Sign Up'),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
              SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  children: [
                    TextSpan(
                      text: _isLoginMode ? 'Do not have an account? ' : 'Already have an account? ',
                    ),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: _toggleLoginSignupMode,
                        child: Text(
                          _isLoginMode ? 'Sign up' : 'Log in',
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(flex: 1),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Other login methods',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 12,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: SignInButton(
                  buttonType: ButtonType.google,
                  onPressed: signInWithGoogle,
                ),
              ),
            const SizedBox(height: 8), // Reduced height to bring buttons closer
            SizedBox(
              width: double.infinity,
              height: 50,
              child: SignInButton(
                buttonType: ButtonType.appleDark,
                onPressed: signInWithApple,
              ),
            ),
              Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
