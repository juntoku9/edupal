import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'app_header.dart'; // add this line
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'login.dart';
import 'homepage.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';

import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui_auth;
import 'package:authing_sdk_v3/authing.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async{

  // initialize firebase 
  WidgetsFlutterBinding.ensureInitialized();
    
if(Firebase.apps.isEmpty){
  print(Firebase.apps);
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
    );
}
  
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // 653004192812-l0rc5u49a5sq9aapmii02ho6jdhmecpf.apps.googleusercontent.com
    // configure ui auth 
    FirebaseUIAuth.configureProviders([
    firebase_ui_auth.EmailAuthProvider(),
    // PhoneAuthProvider(),
    // project-941847190544
    GoogleProvider(clientId: "941847190544-k3pfkt3an49iu1tha9dcq2siji3es9ar.apps.googleusercontent.com"),
    AppleProvider(),
      // ... other providers
    ]);

    // should check if we were to init authing

    final FirebasePerformance performance = FirebasePerformance.instance;
    await performance.setPerformanceCollectionEnabled(true);

  // final metric = FirebasePerformance.instance
  //     .newHttpMetric("https://www.google.com", HttpMethod.Get);

  // await metric.start();
  // final response = await http.get(Uri.parse("https://www.google.com/"));

  //   // Set the response information
  //   metric
  //     ..httpResponseCode = response.statusCode
  //     ..responsePayloadSize = response.contentLength
  //     ..responseContentType = response.headers['content-type'];

  // await metric.stop();

  await dotenv.load(fileName: '.env');
  print(dotenv.env['BACKEND_ADDRESS']);
  // runApp(const MyApp());
  runApp(
    MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => CharacterProvider()),
      ],
      child: MyApp(),
    ),
  );
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  final selectedIndex = ValueNotifier<int>(0);

  void _onRouteChanged(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print("on route changed");
    final settings = route.settings;
    if (settings.name == '/home') {
      setState(() {
        _selectedIndex = 0;
      });
    } else if (settings.name == '/community') {
      setState(() {
        _selectedIndex = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dreamore AI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        // '/home': (context) => MyHomePage(selectedIndex: selectedIndex),
        // '/community': (context) => CommunityPage(selectedIndex: selectedIndex),
        // '/journal': (context) => JournalPage(selectedIndex: selectedIndex),
        // '/verify-email': (context) => EmailVerificationScreen(
        //                               // actionCodeSettings: ActionCodeSettings(...),
        //                               actions: [
        //                                 EmailVerifiedAction(() {
        //                                   Navigator.pushReplacementNamed(context, '/profile');
        //                                 }),
        //                                 AuthCancelledAction((context) {
        //                                   FirebaseUIAuth.signOut(context: context);
        //                                   Navigator.pushReplacementNamed(context, '/');
        //                                 }),
        //                               ],
        //                             ),
      },
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('zh'), // Spanish
        Locale('ja'), // Spanish
      ],
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
