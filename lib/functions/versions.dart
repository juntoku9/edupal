import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_io/io.dart';
import 'package:async/async.dart';

import 'dart:io' show Platform;

bool isUserInChina() {
  String localeName = Platform.localeName;
  return localeName.contains('_CN');
}

Future<String> getCurrentAppVersion() async {
  String localeName = Platform.localeName;
  print("user locale name " + localeName); // en_US
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

Future<String> getMinimumRequiredAppVersion(String backendUrl) async {
  final url = Uri.parse('${dotenv.env['BACKEND_ADDRESS']}/api/user/version');
    final response = await http.get(url);
  if (response.statusCode == 200) {
    return jsonDecode(response.body)['version'];
  } else {
    throw Exception('Failed to fetch minimum required app version');
  }
}

bool isAppVersionValid(String currentVersion, String requiredVersion) {
  List<String> currentVersionParts = currentVersion.split('.');
  List<String> requiredVersionParts = requiredVersion.split('.');

  for (int i = 0; i < currentVersionParts.length && i < requiredVersionParts.length; i++) {
    int currentPart = int.parse(currentVersionParts[i]);
    int requiredPart = int.parse(requiredVersionParts[i]);

    if (currentPart > requiredPart) return true;
    if (currentPart < requiredPart) return false;
  }

  return true;
}

Future<void> _launchURL(String url) async {
  String platformUrl;

  if (Platform.isIOS) {
    platformUrl = 'https://$url';
  } else if (Platform.isAndroid) {
    platformUrl = 'http://$url';
  } else {
    platformUrl = 'https://$url';
  }
  print(platformUrl);
  if (await canLaunch(platformUrl)) {
    await launch(platformUrl);
  } else {
    throw 'Could not launch $platformUrl';
  }
}


class VersionCheckResult {
  final bool isUpToDate;
  final String? errorMessage;

  VersionCheckResult({required this.isUpToDate, this.errorMessage});
}

int _compareVersionNumbers(String v1, String v2) {
  List<String> components1 = v1.split('.');
  List<String> components2 = v2.split('.');
  int length = components1.length > components2.length
      ? components1.length
      : components2.length;
  for (int i = 0; i < length; i++) {
    int c1 = i < components1.length ? int.tryParse(components1[i]) ?? 0 : 0;
    int c2 = i < components2.length ? int.tryParse(components2[i]) ?? 0 : 0;
    if (c1 < c2) {
      return -1;
    } else if (c1 > c2) {
      return 1;
    }
  }
  return 0;
}

// Error handling left to the caller 
Future<bool> checkBackendVersion(BuildContext context, {VoidCallback? onLaterPressed}) async {
    return true;

    final url = Uri.parse('${dotenv.env['BACKEND_ADDRESS']}/api/user/version');
    final metric = FirebasePerformance.instance.newHttpMetric(url.toString(), HttpMethod.Get);
    await metric.start();

    final response = await http.get(url);
    // Set the response information
    metric
      ..httpResponseCode = response.statusCode
      ..responsePayloadSize = response.contentLength
      ..responseContentType = response.headers['content-type'];
    await metric.stop();

    if (response.statusCode == 200) {
      final version =  jsonDecode(response.body)['version'];
      final appVersion = await getCurrentAppVersion();
      print(appVersion +" " + version);
      print(appVersion.compareTo(version) );

        if (_compareVersionNumbers(appVersion, version) < 0 && false) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: Text(
                ' New Update Available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Please update the app to the latest version: ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: version,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onLaterPressed != null) {
                      onLaterPressed();
                    }
                  },
                  child: Text(
                    'Later',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Replace the URL with your app store link
                    _launchURL('apps.apple.com/app/');
                  },
                  child: Text(
                    'Update',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        return false;
        } else {
        return true;
        }
    }else{
      //there is an error
      throw Exception('Failed to fetch minimum required app version');
    }
} 
